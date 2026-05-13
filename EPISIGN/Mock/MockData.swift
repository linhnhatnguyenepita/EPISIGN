import Foundation

enum MockData {
    static let todaysLectures: [Lecture] = [
        Lecture(
            id: "1",
            title: "Probabilités et statistique",
            teacher: "Lorem ipsum",
            startTime: "10:00",
            endTime: "11:30",
            room: "Room 402B • Science Wing",
            status: .checkInOpen,
            group: "DEV2_1",
            hasCheckedIn: false
        ),
        Lecture(
            id: "2",
            title: "Advanced Macroeconomics",
            teacher: "Lorem ipsum",
            startTime: "13:00",
            endTime: "14:30",
            room: "Room 402B • Science Wing",
            status: .upcoming,
            group: "DEV2_1",
            hasCheckedIn: false
        ),
        Lecture(
            id: "3",
            title: "Data Structures",
            teacher: "Lorem ipsum",
            startTime: "15:00",
            endTime: "22:30",
            room: "Room 402B • Science Wing",
            status: .past,
            group: "DEV2_1",
            hasCheckedIn: true
        )
    ]
}
