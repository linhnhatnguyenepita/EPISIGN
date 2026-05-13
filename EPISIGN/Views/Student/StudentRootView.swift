import SwiftUI

enum StudentFlow: Hashable {
    case scan(Lecture)
    case qrScan(Lecture)
    case sign(Lecture, String)
}

struct StudentRootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var path: [StudentFlow] = []

    @StateObject private var viewModel = LectureListViewModel()

    private var lectures: [Lecture] { viewModel.lectures }
    private var lectureForScan: Lecture {
        lectures.first(where: { $0.status == .checkInOpen }) ?? lectures[0]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                ScheduleView(lectures: lectures, onOpenLecture: { lecture in
                    if lecture.status == .checkInOpen {
                        path.append(.scan(lecture))
                    }
                }, onRefresh: {
                    if let uid = appState.userId {
                        await viewModel.fetchLectures(for: .student, userId: uid)
                    }
                })

                ScanFloatingButton {
                    path.append(.scan(lectureForScan))
                }
            }
            .task {
                if let uid = appState.userId {
                    await viewModel.fetchLectures(for: .student, userId: uid)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StudentFlow.self) { flow in
                destinationView(for: flow)
            }
        }
        .onChange(of: appState.role) { path.removeAll() }
    }

    @ViewBuilder
    private func destinationView(for flow: StudentFlow) -> some View {
        switch flow {
        case .scan(let lecture):
            NFCScanView(
                lecture: lecture,
                onScanned: { sessionId in path.append(.sign(lecture, sessionId)) },
                onQRScan: { path.append(.qrScan(lecture)) },
                onDismiss: { path.removeAll() }
            )
            .background(Color.blue)
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)

        case .qrScan(let lecture):
            QRScanView(
                lecture: lecture,
                onScanned: { sessionId in path.append(.sign(lecture, sessionId)) },
                onDismiss: { path.removeLast() }
            )
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)

        case .sign(let lecture, let sessionId):
            SignConfirmView(
                lecture: lecture,
                sessionId: sessionId,
                onSubmit: {
                    path.removeAll()
                    if let uid = appState.userId {
                        Task { await viewModel.fetchLectures(for: .student, userId: uid) }
                    }
                },
                onCancel: { path.removeAll() }
            )
            .background(Color.blue)
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    StudentRootView().environmentObject(AppState())
}
