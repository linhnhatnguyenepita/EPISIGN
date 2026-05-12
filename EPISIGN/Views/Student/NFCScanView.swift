import SwiftUI

struct NFCScanView: View {
    let lecture: Lecture
    var onScanned: (String) -> Void
    var onQRScan: () -> Void
    var onDismiss: () -> Void

    @StateObject private var nfcReader = NFCReaderService()
    @State private var pulse = false
    @State private var statusMessage = "Place your phone near the NFC tag\non the wall or at the lecturer's\npodium to verify your attendance."
    @State private var readError: String?

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
        }
    }

    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IN SESSION")
                .font(AppFonts.dmSans(size: 11, weight: .bold))
                .tracking(0.55)
                .foregroundStyle(AppColors.badgeBlueText)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.badgeBlueBg))

            Text(lecture.title)
                .font(AppFonts.dmSans(size: 24, weight: .bold))
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
                nfcIcon
                    .padding(.vertical, 24)

                VStack(spacing: 16) {
                    Text(nfcReader.isReading ? "Reading NFC" : "Ready to scan")
                        .font(AppFonts.dmSans(size: 24, weight: .bold))
                        .tracking(-0.6)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(statusMessage)
                        .font(AppFonts.dmSans(size: 16))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    if let readError {
                        Text(readError)
                            .font(AppFonts.dmSans(size: 13, weight: .semibold))
                            .foregroundStyle(Color.red.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 16)

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(height: 1)
                    Button {
                        onQRScan()
                    } label: {
                        Text("Can't scan? Scan the QR Code here")
                            .font(AppFonts.dmSans(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.vertical, 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
            }
        }
    }

    private var nfcIcon: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(AppColors.navy.opacity(0.08), lineWidth: 1)
                    .frame(width: 240 + CGFloat(i * 20), height: 240 + CGFloat(i * 20))
                    .scaleEffect(pulse ? 1.05 : 1.0)
                    .opacity(pulse ? 0.6 : 1.0)
            }

            Button {
                readNFC()
            } label: {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppColors.navyGradient)
                            .frame(width: 80, height: 80)
                        Image(systemName: nfcReader.isReading ? "wave.3.right" : "dot.radiowaves.left.and.right")
                            .font(AppFonts.dmSans(size: 30, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .symbolEffect(.pulse, options: .repeating, value: nfcReader.isReading)
                    }
                    VStack(spacing: 4) {
                        Image(systemName: "iphone")
                            .font(AppFonts.dmSans(size: 28))
                            .foregroundStyle(AppColors.navy)
                        Circle()
                            .fill(AppColors.navy)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                )
                .shadow(color: AppColors.navy.opacity(0.08), radius: 48, x: 0, y: 24)
            }
            .buttonStyle(.plain)
            .disabled(nfcReader.isReading)
        }
        .frame(width: 280, height: 280)
    }

    private func readNFC() {
        readError = nil
        statusMessage = "Hold still while EPISIGN reads the NFC tag."

        Task {
            do {
                let sessionID = try await nfcReader.readSessionID()
                statusMessage = "Read session \(sessionID).\nPreparing attendance confirmation."
                onScanned(sessionID)
            } catch {
                readError = error.localizedDescription
                statusMessage = "Place your phone near the NFC tag\non the wall or at the lecturer's\npodium to verify your attendance."
            }
        }
    }
}

#Preview {
    NFCScanView(lecture: MockData.todaysLectures[0], onScanned: { _ in }, onQRScan: {}, onDismiss: {})
}
