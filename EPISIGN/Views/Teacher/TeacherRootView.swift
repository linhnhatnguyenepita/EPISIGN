import SwiftUI

enum TeacherFlow: Hashable {
    case scan(Lecture)
}

struct TeacherRootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var path: [TeacherFlow] = []

    private let lectures = MockData.todaysLectures

    private var lectureForScan: Lecture {
        lectures.first(where: { $0.status == .checkInOpen }) ?? lectures[0]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                ScheduleView(lectures: lectures) { lecture in
                    path.append(.scan(lecture))
                }

                ScanFloatingButton {
                    path.append(.scan(lectureForScan))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TeacherFlow.self) { flow in
                destinationView(for: flow)
            }
        }
        .onChange(of: appState.role) { path.removeAll() }
    }

    @ViewBuilder
    private func destinationView(for flow: TeacherFlow) -> some View {
        switch flow {
        case .scan(let lecture):
            TeacherNFCScanView(
                lecture: lecture,
                onNFCWrite: {},
                onSessionExpired: { path.removeAll() },
                onDismiss: { path.removeAll() }
            )
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    let state = AppState()
    state.role = .teacher
    return TeacherRootView().environmentObject(state)
}
