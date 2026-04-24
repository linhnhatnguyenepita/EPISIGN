import Foundation

enum LectureStatus {
    case checkInOpen
    case upcoming
    case past
}

struct Lecture: Identifiable, Hashable {
    let id: String
    let title: String
    let teacher: String
    let startTime: String
    let endTime: String
    let room: String
    let status: LectureStatus

    var timeRange: String { "\(startTime) - \(endTime)" }
}
