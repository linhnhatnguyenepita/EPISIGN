import SwiftUI

enum TeacherFlow: Hashable {
    case scan(Lecture)
}

struct TeacherRootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var path: [TeacherFlow] = []

    @StateObject private var viewModel = LectureListViewModel()

    private var lectures: [Lecture] { viewModel.lectures }
    private var lectureForScan: Lecture {
        lectures.first(where: { $0.status == .checkInOpen }) ?? lectures[0]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                ScheduleView(lectures: lectures, onOpenLecture: { lecture in
                    path.append(.scan(lecture))
                }, onRefresh: {
                    if let uid = appState.userId {
                        await viewModel.fetchLectures(for: .teacher, userId: uid)
                    }
                })

                ScanFloatingButton {
                    path.append(.scan(lectureForScan))
                }
            }
            .task {
                if let uid = appState.userId {
                    await viewModel.fetchLectures(for: .teacher, userId: uid)
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
