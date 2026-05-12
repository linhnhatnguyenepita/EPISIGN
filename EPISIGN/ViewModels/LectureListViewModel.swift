import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class LectureListViewModel: ObservableObject {
    @Published var lectures: [Lecture] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    func fetchLectures(for role: AppRole, userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let query: Query
            if role == .teacher {
                query = db.collection("lectures").whereField("teacherId", isEqualTo: userId)
            } else {
                query = db.collection("lectures").whereField("studentIds", arrayContains: userId)
            }
            let snapshot = try await query.order(by: "scheduledAt", descending: false).getDocuments()
            
            var fetchedLectures: [Lecture] = []
            
            for doc in snapshot.documents {
                let data = doc.data()
                let title = data["title"] as? String ?? "Unknown"
                let room = data["room"] as? String ?? "Room TBD"
                let group = data["subject"] as? String ?? ""
                
                // Fetch teacher name
                var teacherName = "Unknown Teacher"
                if let teacherId = data["teacherId"] as? String {
                    if let tDoc = try? await db.collection("users").document(teacherId).getDocument(),
                       let tName = tDoc.data()?["displayName"] as? String {
                        teacherName = tName
                    }
                }
                
                // Handle times and status
                let scheduledAt = (data["scheduledAt"] as? Timestamp)?.dateValue() ?? Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let startTime = formatter.string(from: scheduledAt)
                
                let endTimeDate = scheduledAt.addingTimeInterval(3600 * 1.5) // 1.5 hours
                let endTime = formatter.string(from: endTimeDate)
                
                let now = Date()
                let status: LectureStatus
                if now >= scheduledAt && now <= endTimeDate {
                    status = .checkInOpen
                } else if now > endTimeDate {
                    status = .past
                } else {
                    status = .upcoming
                }
                
                fetchedLectures.append(Lecture(
                    id: doc.documentID,
                    title: title,
                    teacher: teacherName,
                    startTime: startTime,
                    endTime: endTime,
                    room: room,
                    status: status,
                    group: group
                ))
            }
            
            self.lectures = fetchedLectures
        } catch {
            self.errorMessage = "Impossible de charger les cours : \(error.localizedDescription)"
        }
        isLoading = false
    }
}
