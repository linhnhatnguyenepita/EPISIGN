import SwiftUI
import Combine

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
}
