import Foundation
import Combine
import CoreNFC

enum NFCReadError: LocalizedError {
    case unavailable
    case alreadyReading
    case emptyTag
    case unsupportedPayload

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "NFC scanning is not available on this device."
        case .alreadyReading:
            return "An NFC scan is already in progress."
        case .emptyTag:
            return "This NFC tag does not contain a session code."
        case .unsupportedPayload:
            return "EPISIGN could not read the NFC tag payload."
        }
    }
}

final class NFCReaderService: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published private(set) var isReading = false
    @Published private(set) var lastSessionID: String?

    private var session: NFCNDEFReaderSession?
    private var readContinuation: CheckedContinuation<String, Error>?

    func readSessionID() async throws -> String {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NFCReadError.unavailable
        }

        guard readContinuation == nil else {
            throw NFCReadError.alreadyReading
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.isReading = true
                self.readContinuation = continuation

                let session = NFCNDEFReaderSession(
                    delegate: self,
                    queue: nil,
                    invalidateAfterFirstRead: true
                )
                session.alertMessage = "Hold your iPhone near the EPISIGN NFC tag."
                self.session = session
                session.begin()
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let sessionID = Self.sessionID(from: messages) else {
            session.alertMessage = "No EPISIGN session code found."
            complete(with: .failure(NFCReadError.emptyTag))
            return
        }

        session.alertMessage = "EPISIGN session code read."
        complete(with: .success(sessionID))
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        complete(with: .failure(error))
    }

    private func complete(with result: Result<String, Error>) {
        DispatchQueue.main.async {
            guard let continuation = self.readContinuation else { return }

            self.readContinuation = nil
            self.session = nil
            self.isReading = false

            switch result {
            case .success(let sessionID):
                self.lastSessionID = sessionID
                continuation.resume(returning: sessionID)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }

    private static func sessionID(from messages: [NFCNDEFMessage]) -> String? {
        messages
            .flatMap(\.records)
            .compactMap { sessionID(from: $0) }
            .first
    }

    private static func sessionID(from record: NFCNDEFPayload) -> String? {
        if let text = textPayload(from: record) {
            return text
        }

        if let uri = record.wellKnownTypeURIPayload()?.absoluteString {
            return uri
        }

        return String(data: record.payload, encoding: .utf8)
            .flatMap(normalizedSessionID)
    }

    private static func textPayload(from record: NFCNDEFPayload) -> String? {
        guard record.typeNameFormat == .nfcWellKnown,
              String(data: record.type, encoding: .utf8) == "T",
              let statusByte = record.payload.first
        else { return nil }

        let languageCodeLength = Int(statusByte & 0x3F)
        let textStartIndex = 1 + languageCodeLength
        guard record.payload.count > textStartIndex else { return nil }

        let textData = record.payload.dropFirst(textStartIndex)
        return String(data: textData, encoding: .utf8)
            .flatMap(normalizedSessionID)
    }

    private static func normalizedSessionID(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
