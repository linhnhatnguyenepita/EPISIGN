import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

enum AppRole: String {
    case student
    case teacher

    var label: String {
        switch self {
        case .student: return "Student"
        case .teacher: return "Teacher"
        }
    }

    var icon: String {
        switch self {
        case .student: return "graduationcap.fill"
        case .teacher: return "person.fill"
        }
    }
}

class AppState: ObservableObject {
    @Published var role: AppRole = .student
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    private var authHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                if let user = user {
                    await self.resolveRole(uid: user.uid)
                    self.isAuthenticated = true
                } else {
                    self.isAuthenticated = false
                }
                self.isLoading = false
            }
        }
    }

    deinit {
        if let h = authHandle { Auth.auth().removeStateDidChangeListener(h) }
    }

    private func resolveRole(uid: String) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if let r = doc.data()?["role"] as? String, let appRole = AppRole(rawValue: r) {
                role = appRole
                return
            }
            let token = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
            if let r = token?.claims["role"] as? String, let appRole = AppRole(rawValue: r) {
                role = appRole
            }
        } catch {}
    }

    func login(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await resolveRole(uid: result.user.uid)
            isAuthenticated = true
        } catch let error as NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .wrongPassword, .invalidEmail, .userNotFound:
                errorMessage = "Email or password incorrect."
            case .networkError:
                errorMessage = "No network connection."
            default:
                errorMessage = error.localizedDescription
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }

    var userId: String? { Auth.auth().currentUser?.uid }
}
