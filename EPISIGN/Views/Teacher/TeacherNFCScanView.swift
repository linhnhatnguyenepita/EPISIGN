import SwiftUI
import UserNotifications

struct TeacherNFCScanView: View {
    let lecture: Lecture
    var onNFCWrite: () -> Void
    var onSessionExpired: () -> Void
    var onDismiss: () -> Void

    @State private var pulse = false
    @State private var sessionStarted = false
    @State private var secondsRemaining = 600
    @State private var sessionTimer: Timer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                courseHeader
                scanCard
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 128)
        }
        .background(AppColors.background)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
            requestNotificationPermission()
        }
        .onDisappear {
            sessionTimer?.invalidate()
        }
    }

    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sessionStarted ? "IN SESSION" : "READY")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.55)
                .foregroundStyle(AppColors.badgeBlueText)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.badgeBlueBg))

            Text(lecture.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, 4)

            HStack(spacing: 12) {
                Image(systemName: "person.circle")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                Text(lecture.teacher)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var scanCard: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .fill(AppColors.headerBg)

            VStack(spacing: 0) {
                countdownBanner
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                nfcWriteIcon
                    .padding(.vertical, 24)

                VStack(spacing: 16) {
                    Text(sessionStarted ? "Session Active" : "Write Session ID")
                        .font(.system(size: 24, weight: .bold))
                        .tracking(-0.6)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(sessionStarted
                         ? "The NFC tag is active.\nStudents can check in until the session expires."
                         : "Tap the NFC tag in your classroom\nto write the session ID and start\nthe 10-minute check-in window.")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.2), value: sessionStarted)

                Spacer(minLength: 16)

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(height: 1)
                    Button {
                        cancelSession()
                        onDismiss()
                    } label: {
                        Text("Cancel session")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.red.opacity(0.7))
                            .padding(.vertical, 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
            }
        }
    }

    private var countdownBanner: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(sessionStarted
                          ? (secondsRemaining > 60 ? AppColors.accentGreen : Color.red)
                          : AppColors.textTertiary)
                    .frame(width: 7, height: 7)
                Text(sessionStarted ? "SESSION ACTIVE" : "TAP NFC TO START")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Text(timeFormatted)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    sessionStarted
                        ? (secondsRemaining > 60 ? AppColors.textHeading : Color.red)
                        : AppColors.textTertiary
                )
                .contentTransition(.numericText())
                .animation(.default, value: secondsRemaining)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.surface)
                .shadow(color: AppColors.navy.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }

    private var nfcWriteIcon: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(AppColors.navy.opacity(sessionStarted ? 0.04 : 0.08), lineWidth: 1)
                    .frame(width: 240 + CGFloat(i * 20), height: 240 + CGFloat(i * 20))
                    .scaleEffect(pulse ? 1.05 : 1.0)
                    .opacity(pulse ? 0.6 : 1.0)
            }

            Button {
                guard !sessionStarted else { return }
                sessionStarted = true
                startSession()
                onNFCWrite()
            } label: {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(sessionStarted
                                  ? LinearGradient(
                                        colors: [AppColors.accentGreen, Color(hex: 0x1A7A55)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                  : AppColors.navyGradient)
                            .frame(width: 80, height: 80)
                        Image(systemName: sessionStarted ? "checkmark" : "pencil.and.list.clipboard")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .animation(.spring(response: 0.3), value: sessionStarted)
                    }
                    VStack(spacing: 4) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 28))
                            .foregroundStyle(sessionStarted ? AppColors.accentGreen : AppColors.navy)
                        Circle()
                            .fill(sessionStarted ? AppColors.accentGreen : AppColors.navy)
                            .frame(width: 6, height: 6)
                    }
                    .animation(.easeInOut(duration: 0.2), value: sessionStarted)
                }
                .padding(40)
                .background(RoundedRectangle(cornerRadius: 32).fill(Color.white))
                .shadow(color: AppColors.navy.opacity(0.08), radius: 48, x: 0, y: 24)
            }
            .buttonStyle(.plain)
            .disabled(sessionStarted)
        }
        .frame(width: 280, height: 280)
    }

    private var timeFormatted: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startSession() {
        secondsRemaining = 600
        scheduleExpirationNotification()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    sessionTimer?.invalidate()
                    onSessionExpired()
                }
            }
        }
    }

    private func cancelSession() {
        sessionTimer?.invalidate()
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["episign-session-\(lecture.id)"]
        )
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleExpirationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Session Expired"
        content.body = "The signing session for \"\(lecture.title)\" has ended. No more check-ins are accepted."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
        let request = UNNotificationRequest(
            identifier: "episign-session-\(lecture.id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    let state = AppState()
    state.role = .teacher
    return TeacherNFCScanView(
        lecture: MockData.todaysLectures[0],
        onNFCWrite: {},
        onSessionExpired: {},
        onDismiss: {}
    )
    .environmentObject(state)
    .safeAreaInset(edge: .top, spacing: 0) { TopAppBar().environmentObject(state) }
}
