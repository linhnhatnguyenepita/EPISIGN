import SwiftUI

struct SignatureStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
}

struct SignaturePad: View {
    @Binding var strokes: [SignatureStroke]

    var body: some View {
        Canvas { ctx, _ in
            for stroke in strokes {
                var path = Path()
                guard let first = stroke.points.first else { continue }
                path.move(to: first)
                for p in stroke.points.dropFirst() { path.addLine(to: p) }
                ctx.stroke(path, with: .color(AppColors.textPrimary), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if var last = strokes.last, last.points.count > 0, !isGestureBeginning(value) {
                        last.points.append(value.location)
                        strokes[strokes.count - 1] = last
                    } else {
                        strokes.append(SignatureStroke(points: [value.location]))
                    }
                }
                .onEnded { _ in
                    strokes.append(SignatureStroke(points: []))
                }
        )
    }

    private func isGestureBeginning(_ value: DragGesture.Value) -> Bool {
        guard let last = strokes.last else { return true }
        return last.points.isEmpty
    }
}

struct SignConfirmView: View {
    let lecture: Lecture
    let sessionId: String
    var onSubmit: () -> Void
    var onCancel: () -> Void

    @State private var strokes: [SignatureStroke] = []
    @State private var showConfirmed = false
    @State private var errorMessage: String? = nil
    @State private var isSubmitting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                instructional
                signatureCard
                submitActions
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 140)
        }
        .background(AppColors.background)
        .overlay(alignment: .top) {
            if showConfirmed {
                confirmedToast
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(AppFonts.dmSans(size: 14))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showConfirmed)
    }

    private var instructional: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Complete Attendance")
                .font(AppFonts.bricolage(size: 24, weight: .heavy))
                .tracking(-0.75)
                .foregroundStyle(AppColors.textHeading)
            (Text("Provide your signature to complete attendance for ")
                .foregroundStyle(AppColors.textSecondary)
             + Text(lecture.title)
                .foregroundStyle(AppColors.textHeading)
                .font(AppFonts.dmSans(size: 14, weight: .semibold))
             + Text(".")
                .foregroundStyle(AppColors.textSecondary))
                .font(AppFonts.dmSans(size: 14))
                .lineSpacing(4)
        }
    }

    private var signatureCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SIGNATURE PAD")
                    .font(AppFonts.dmSans(size: 14, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Button {
                    strokes.removeAll()
                } label: {
                    Text("Clear Pad")
                        .font(AppFonts.dmSans(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppColors.divider).frame(height: 1)
            }

            ZStack {
                Color(hex: 0xF0F4F8).opacity(0.3)
                SignaturePad(strokes: $strokes)
                    .padding(.horizontal, 24)
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(AppColors.cardBorder)
                        .frame(height: 2)
                        .padding(.horizontal, 48)
                        .padding(.bottom, 48)
                }
                VStack(alignment: .leading) {
                    Spacer()
                    Text("X SIGN HERE")
                        .font(AppFonts.dmSans(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppColors.textTertiary)
                        .padding(.leading, 48)
                        .padding(.bottom, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(height: 256)

            HStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .font(AppFonts.dmSans(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                Text("Your signature is encrypted and stored as proof of presence.")
                    .font(AppFonts.dmSans(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
            }
            .padding(24)
            .background(AppColors.avatarBg.opacity(0.3))
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surface)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: AppColors.navy.opacity(0.04), radius: 24, x: 0, y: 4)
    }

    private var submitActions: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    isSubmitting = true
                    errorMessage = nil
                    do {
                        let result = try await FirebaseFunctionsService.shared.checkin(sessionId: sessionId, lectureId: lecture.id)
                        if result.success {
                            withAnimation { showConfirmed = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onSubmit()
                            }
                        } else {
                            errorMessage = result.message
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    isSubmitting = false
                }
            } label: {
                HStack(spacing: 12) {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Submit Attendance")
                            .font(AppFonts.dmSans(size: 18, weight: .bold))
                            .foregroundStyle(Color.white)
                        Image(systemName: "checkmark.circle.fill")
                            .font(AppFonts.dmSans(size: 20))
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.navyGradient)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(strokes.flatMap { $0.points }.isEmpty || isSubmitting)
            .opacity(strokes.flatMap { $0.points }.isEmpty || isSubmitting ? 0.6 : 1.0)

            Button(action: onCancel) {
                Text("Cancel and exit")
                    .font(AppFonts.dmSans(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
    }

    private var confirmedToast: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.avatarBg)
                    .frame(width: 46, height: 46)
                Image(systemName: "party.popper.fill")
                    .font(AppFonts.dmSans(size: 20))
                    .foregroundStyle(AppColors.accentGreen)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Attendance Confirmed")
                    .font(AppFonts.dmSans(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.textHeading)
                Text("Success! Your presence has been logged for today.")
                    .font(AppFonts.dmSans(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(.leading, 28)
        .padding(.trailing, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(AppColors.accentGreen)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 8)
    }
}

#Preview {
    SignConfirmView(lecture: MockData.todaysLectures[0], sessionId: "mock-session", onSubmit: {}, onCancel: {})
}
