import SwiftUI

struct ScheduleView: View {
    let lectures: [Lecture]
    var onOpenLecture: (Lecture) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                ForEach(lectures) { lecture in
                    Button {
                        onOpenLecture(lecture)
                    } label: {
                        LectureCard(lecture: lecture)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack {
            Text("Today's Lectures")
                .font(AppFonts.bricolage(size: 20, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("\(lectures.count) Sessions")
                .font(AppFonts.dmSans(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textHeading)
        }
    }
}

struct LectureCard: View {
    let lecture: Lecture

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            statusBadge
            Text(lecture.title)
                .font(AppFonts.dmSans(size: 20, weight: .bold))
                .foregroundStyle(AppColors.textHeading)
                .multilineTextAlignment(.leading)
            Text(lecture.teacher)
                .font(AppFonts.dmSans(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(AppFonts.dmSans(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                Text(lecture.timeRange)
                    .font(AppFonts.dmSans(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Text(lecture.room)
                .font(AppFonts.dmSans(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(26)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    lecture.status == .checkInOpen ? AppColors.accentGreen : AppColors.cardBorder.opacity(0.3),
                    lineWidth: lecture.status == .checkInOpen ? 2 : 1
                )
        )
        .shadow(color: AppColors.navy.opacity(0.04), radius: 24, x: 0, y: 4)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch lecture.status {
        case .checkInOpen:
            HStack(spacing: 6) {
                Circle()
                    .fill(AppColors.accentGreen)
                    .frame(width: 6, height: 6)
                Text("CHECK-IN OPEN")
                    .font(AppFonts.dmSans(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppColors.accentGreen)
            }
        case .upcoming:
            Text("UPCOMING")
                .font(AppFonts.dmSans(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppColors.upcomingText)
        case .past:
            Text("COMPLETED")
                .font(AppFonts.dmSans(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)
        }
    }
}

#Preview {
    ScheduleView(lectures: MockData.todaysLectures, onOpenLecture: { _ in })
}
