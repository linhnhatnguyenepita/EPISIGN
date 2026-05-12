import Foundation
import FirebaseFunctions

class FirebaseFunctionsService {
    static let shared = FirebaseFunctionsService()
    private let functions = Functions.functions(region: "europe-west1")

    private init() {}

    func startSession(lectureId: String) async throws -> String {
        let result = try await functions.httpsCallable("startSession").call(["lectureId": lectureId])
        guard let data = result.data as? [String: Any],
              let sessionId = data["sessionId"] as? String else {
            throw FunctionsError.unexpectedResponse
        }
        return sessionId
    }

    func checkin(sessionId: String, lectureId: String) async throws -> CheckinResult {
        let result = try await functions.httpsCallable("checkin").call([
            "sessionId": sessionId,
            "lectureId": lectureId
        ])
        guard let data = result.data as? [String: Any] else {
            throw FunctionsError.unexpectedResponse
        }
        let success = data["success"] as? Bool ?? false
        let message = data["message"] as? String ?? "Présence enregistrée."
        return CheckinResult(success: success, message: message)
    }

    enum FunctionsError: LocalizedError {
        case unexpectedResponse
        var errorDescription: String? { "Réponse inattendue du serveur." }
    }
}

struct CheckinResult {
    let success: Bool
    let message: String
}
