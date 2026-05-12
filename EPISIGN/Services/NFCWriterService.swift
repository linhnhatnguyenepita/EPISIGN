import Foundation
import CoreNFC

class NFCWriterService: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {

    @Published var writeSuccess: Bool = false
    @Published var writeError: String? = nil

    private var session: NFCNDEFReaderSession?
    private var tokenToWrite: String = ""
    private var completion: ((Result<Void, Error>) -> Void)?

    enum NFCError: LocalizedError {
        case noTagFound
        case tagNotWritable
        case writeFailed(String)

        var errorDescription: String? {
            switch self {
            case .noTagFound: return "Aucun tag NFC détecté."
            case .tagNotWritable: return "Ce tag NFC n'est pas accessible en écriture."
            case .writeFailed(let msg): return "Échec de l'écriture : \(msg)"
            }
        }
    }

    func write(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.tokenToWrite = token
        self.completion = completion
        self.writeSuccess = false
        self.writeError = nil

        session = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: false)
        session?.alertMessage = "Approchez votre iPhone du tag NFC placé en salle de cours."
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let nsError = error as NSError
        if nsError.code != 200 {
            DispatchQueue.main.async {
                self.writeError = error.localizedDescription
                self.completion?(.failure(error))
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "Aucun tag détecté.")
            completion?(.failure(NFCError.noTagFound))
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connexion échouée.")
                self.completion?(.failure(error))
                return
            }

            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: "Erreur de lecture du tag.")
                    self.completion?(.failure(error))
                    return
                }

                guard status == .readWrite else {
                    session.invalidate(errorMessage: "Ce tag est en lecture seule.")
                    self.completion?(.failure(NFCError.tagNotWritable))
                    return
                }

                let payload = NFCNDEFPayload.wellKnownTypeTextPayload(
                    string: self.tokenToWrite,
                    locale: Locale(identifier: "en")
                )!
                let message = NFCNDEFMessage(records: [payload])

                tag.writeNDEF(message) { error in
                    if let error = error {
                        session.invalidate(errorMessage: "Écriture échouée.")
                        self.completion?(.failure(NFCError.writeFailed(error.localizedDescription)))
                    } else {
                        session.alertMessage = "✅ Session écrite sur le tag !"
                        session.invalidate()
                        DispatchQueue.main.async {
                            self.writeSuccess = true
                            self.completion?(.success(()))
                        }
                    }
                }
            }
        }
    }
}
