import SwiftUI
import UserNotifications
import CoreImage
import CoreImage.CIFilterBuiltins

struct TeacherNFCScanView: View {
    let lecture: Lecture
    var onNFCWrite: () -> Void
    var onSessionExpired: () -> Void
    var onDismiss: () -> Void

    @State private var pulse = false
    @State private var sessionStarted = false
    @State private var secondsRemaining = 600
    @State private var sessionTimer: Timer?
    @State private var showQRPopup = false
    @State private var sessionQRToken: String = UUID().uuidString
    @StateObject private var nfcWriter = NFCWriterService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                courseHeader
                scanCard
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .background(AppColors.background)
        .overlay {
            if showQRPopup {
                qrPopupOverlay
            }
        }
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
                .font(AppFonts.dmSans(size: 11, weight: .bold))
                .tracking(0.55)
                .foregroundStyle(AppColors.badgeBlueText)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.badgeBlueBg))

            Text(lecture.title)
                .font(AppFonts.bricolage(size: 24, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, 4)

            HStack(spacing: 12) {
                Image(systemName: "person.circle")
                    .font(AppFonts.dmSans(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                Text(lecture.teacher)
                    .font(AppFonts.dmSans(size: 18, weight: .medium))
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
                    .padding(.vertical, 8)

                VStack(spacing: 16) {
                    Text(sessionStarted ? "Session Active" : "Write Session ID")
                        .font(AppFonts.dmSans(size: 24, weight: .bold))
                        .tracking(-0.6)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(sessionStarted
                         ? "The NFC tag is active.\nStudents can check in until the session expires."
                         : "Tap the NFC tag in your classroom\nto write the session ID and start\nthe 10-minute check-in window.")
                        .font(AppFonts.dmSans(size: 16))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.2), value: sessionStarted)

                Spacer(minLength: 16)

                VStack(spacing: 0) {
                    if sessionStarted {
                        Button {
                            showQRPopup = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "qrcode")
                                    .font(AppFonts.dmSans(size: 16, weight: .semibold))
                                Text("Show QR Code")
                                    .font(AppFonts.dmSans(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.navyGradient)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(height: 1)
                    Button {
                        cancelSession()
                        onDismiss()
                    } label: {
                        Text("Cancel session")
                            .font(AppFonts.dmSans(size: 14, weight: .semibold))
                            .foregroundStyle(Color.red.opacity(0.7))
                            .padding(.vertical, 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
                .animation(.easeInOut(duration: 0.2), value: sessionStarted)
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
                    .font(AppFonts.dmSans(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Text(timeFormatted)
                .font(AppFonts.dmSans(size: 22, weight: .bold))
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
                            .font(AppFonts.dmSans(size: 30, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .animation(.spring(response: 0.3), value: sessionStarted)
                    }
                    VStack(spacing: 4) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(AppFonts.dmSans(size: 28))
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

    private var qrPopupOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { showQRPopup = false }

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("QR Code")
                        .font(AppFonts.bricolage(size: 20, weight: .bold))
                        .foregroundStyle(AppColors.textHeading)
                    Text("One-time session code for \(lecture.title)")
                        .font(AppFonts.dmSans(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let qrImage = generateQRImage(from: sessionQRToken) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.headerBg)
                        .frame(width: 220, height: 220)
                        .overlay {
                            Image(systemName: "qrcode")
                                .font(.system(size: 60))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                }

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(AppFonts.dmSans(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                    Text("Expires in \(timeFormatted)")
                        .font(AppFonts.dmSans(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .contentTransition(.numericText())
                        .animation(.default, value: secondsRemaining)
                }

                Text("Tap outside to dismiss")
                    .font(AppFonts.dmSans(size: 12))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColors.surface)
                    .shadow(color: Color.black.opacity(0.15), radius: 32, x: 0, y: 12)
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: showQRPopup)
    }

    private func generateQRImage(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private var timeFormatted: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startSession() {
        Task {
            do {
                let sessionId = try await FirebaseFunctionsService.shared.startSession(lectureId: lecture.id)
                sessionQRToken = sessionId
                
                nfcWriter.write(token: sessionId) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            secondsRemaining = 600
                            scheduleExpirationNotification()
                            sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                if secondsRemaining > 0 {
                                    secondsRemaining -= 1
                                } else {
                                    sessionTimer?.invalidate()
                                    onSessionExpired()
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            sessionStarted = false
                            print("NFC Write failed: \(error)")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    sessionStarted = false
                    print("Failed to start session: \(error)")
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
