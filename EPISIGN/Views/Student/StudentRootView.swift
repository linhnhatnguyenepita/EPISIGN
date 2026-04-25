import SwiftUI

enum StudentFlow: Hashable {
    case scan(Lecture)
    case qrScan(Lecture)
    case sign(Lecture)
}

struct StudentRootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var path: [StudentFlow] = []

    private let lectures = MockData.todaysLectures

    private var lectureForScan: Lecture {
        lectures.first(where: { $0.status == .checkInOpen }) ?? lectures[0]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                ScheduleView(lectures: lectures) { lecture in
                    if lecture.status == .checkInOpen {
                        path.append(.scan(lecture))
                    }
                }

                ScanFloatingButton {
                    path.append(.scan(lectureForScan))
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
                onScanned: { path.append(.sign(lecture)) },
                onQRScan: { path.append(.qrScan(lecture)) },
                onDismiss: { path.removeAll() }
            )
            .background(Color.blue)
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)

        case .qrScan(let lecture):
            QRScanView(
                lecture: lecture,
                onScanned: { path.append(.sign(lecture)) },
                onDismiss: { path.removeLast() }
            )
            .safeAreaInset(edge: .top, spacing: 0) { TopAppBar() }
            .toolbar(.hidden, for: .navigationBar)

        case .sign(let lecture):
            SignConfirmView(
                lecture: lecture,
                onSubmit: { path.removeAll() },
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
