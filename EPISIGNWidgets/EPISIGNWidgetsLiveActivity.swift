//
//  EPISIGNWidgetsLiveActivity.swift
//  EPISIGNWidgets
//
//  Created by Nhat Linh on 13/05/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

private let brandNavy = Color(red: 0.07, green: 0.13, blue: 0.32)

struct EPISIGNWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionAttributes.self) { context in
            HStack(spacing: 12) {
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(brandNavy))

                VStack(alignment: .leading, spacing: 2) {
                    Text("EPISIGN session")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                    Text(context.attributes.lectureTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text(timerInterval: Date()...context.state.endDate, countsDown: true)
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .activityBackgroundTint(brandNavy)
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.and.list.clipboard")
                            .foregroundStyle(.white)
                        Text("Signing")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.endDate, countsDown: true)
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.lectureTitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                }
            } compactLeading: {
                Image(systemName: "pencil.and.list.clipboard")
                    .foregroundStyle(.white)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.endDate, countsDown: true)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 56)
            } minimal: {
                Text(timerInterval: Date()...context.state.endDate,
                     countsDown: true,
                     showsHours: false)
                    .font(.caption2.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .keylineTint(brandNavy)
        }
    }
}

extension SessionAttributes {
    fileprivate static var preview: SessionAttributes {
        SessionAttributes(lectureTitle: "Algorithms 101", lectureId: "lec-1")
    }
}

extension SessionAttributes.ContentState {
    fileprivate static var fresh: SessionAttributes.ContentState {
        SessionAttributes.ContentState(endDate: Date().addingTimeInterval(600))
    }

    fileprivate static var ending: SessionAttributes.ContentState {
        SessionAttributes.ContentState(endDate: Date().addingTimeInterval(45))
    }
}

#Preview("Notification", as: .content, using: SessionAttributes.preview) {
    EPISIGNWidgetsLiveActivity()
} contentStates: {
    SessionAttributes.ContentState.fresh
    SessionAttributes.ContentState.ending
}
