import Foundation

enum MockData {
    static let todaysLectures: [Lecture] = [
        Lecture(
            id: "1",
            title: "Probabilités et statistique",
            teacher: "Lorem ipsum",
            startTime: "10:00 AM",
            endTime: "11:30 AM",
            room: "Room 402B • Science Wing",
            status: .checkInOpen
        ),
        Lecture(
            id: "2",
            title: "Advanced Macroeconomics",
            teacher: "Lorem ipsum",
            startTime: "1:00 PM",
            endTime: "2:30 PM",
            room: "Room 402B • Science Wing",
            status: .upcoming
        ),
        Lecture(
            id: "3",
            title: "Data Structures",
            teacher: "Lorem ipsum",
            startTime: "3:00 PM",
            endTime: "4:30 PM",
            room: "Room 402B • Science Wing",
            status: .upcoming
        )
    ]
}
