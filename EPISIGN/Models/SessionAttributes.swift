import ActivityKit
import Foundation

struct SessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endDate: Date
    }

    var lectureTitle: String
    var lectureId: String
}
