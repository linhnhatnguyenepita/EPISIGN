import SwiftUI

struct ScheduleView: View {
    let lectures: [Lecture]
    var onOpenLecture: (Lecture) -> Void
    var onRefresh: (() async -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                lectureTimeline
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .refreshable {
            await onRefresh?()
        }
        .background(AppColors.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text("Today's Lectures")
                .font(AppFonts.bricolage(size: 20, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("\(lectures.count) Sessions")
                .font(AppFonts.dmSans(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.navy)
        }
    }

    private var lectureTimeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(lectures.enumerated()), id: \.element.id) { index, lecture in
                Button {
                    onOpenLecture(lecture)
                } label: {
                    TimelineLectureRow(lecture: lecture)
                }
                .buttonStyle(.plain)

                if index < lectures.count - 1 {
                    TimelineDashedDivider()
                        .padding(.leading, 52)
                        .padding(.vertical, 2)
                }
            }
        }
    }
}

struct TimelineLectureRow: View {
    let lecture: Lecture

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            timeColumn
            LectureCard(lecture: lecture)
        }
    }

    private var timeColumn: some View {
        VStack(spacing: 8) {
            Text(lecture.startTime)
                .font(AppFonts.dmSans(size: 14, weight: .semibold))
                .foregroundStyle(lecture.status == .checkInOpen ? AppColors.accentGreen : AppColors.navy)
                .frame(width: 42, alignment: .center)

            TimelineDashedVerticalLine(active: lecture.status == .checkInOpen)
                .frame(width: 2)
                .frame(maxHeight: .infinity)

            Text(lecture.endTime)
                .font(AppFonts.dmSans(size: 14, weight: .semibold))
                .foregroundStyle(lecture.status == .checkInOpen ? AppColors.accentGreen : AppColors.navy)
                .frame(width: 42, alignment: .center)
        }
    }
}

struct TimelineDashedVerticalLine: View {
    let active: Bool

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 1, y: 0))
                path.addLine(to: CGPoint(x: 1, y: geo.size.height))
            }
            .stroke(
                active ? AppColors.accentGreen : Color(hex: 0xC4C6D1),
                style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
            )
        }
    }
}

struct TimelineDashedDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0.5))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0.5))
            }
            .stroke(
                Color(hex: 0xC4C6D1).opacity(0.5),
                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
            )
        }
        .frame(height: 1)
        .padding(.vertical, 16)
    }
}

struct LectureCard: View {
    let lecture: Lecture

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusTab
            cardBody
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: AppColors.navy.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private var statusTab: some View {
        let (bg, content): (Color, AnyView) = switch lecture.status {
        case .checkInOpen:
            (AppColors.accentGreen, AnyView(checkInOpenLabel))
        case .upcoming:
            (AppColors.navy, AnyView(upcomingLabel))
        case .past:
            (Color(hex: 0x6B7280), AnyView(completedLabel))
        }

        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bg)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 12
                )
            )
    }

    private var checkInOpenLabel: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
            Text("CHECK-IN OPEN")
                .font(AppFonts.dmSans(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white)
        }
    }

    private var upcomingLabel: some View {
        Text("UPCOMING")
            .font(AppFonts.dmSans(size: 10, weight: .bold))
            .tracking(1)
            .foregroundStyle(.white)
    }

    private var completedLabel: some View {
        Text("COMPLETED")
            .font(AppFonts.dmSans(size: 10, weight: .bold))
            .tracking(1)
            .foregroundStyle(.white)
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lecture.title)
                .font(AppFonts.dmSans(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: 0x111111))
                .multilineTextAlignment(.leading)
            Text(lecture.teacher)
                .font(AppFonts.dmSans(size: 14))
                .foregroundStyle(AppColors.textSecondary)
            Text(lecture.room)
                .font(AppFonts.dmSans(size: 13))
                .foregroundStyle(AppColors.textSecondary)
            Text(lecture.group)
                .font(AppFonts.dmSans(size: 13, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 24,
                bottomTrailingRadius: 24,
                topTrailingRadius: 24
            )
        )
    }
}

#Preview {
    ScheduleView(lectures: MockData.todaysLectures, onOpenLecture: { _ in }, onRefresh: nil)
}
