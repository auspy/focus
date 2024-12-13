import Foundation

struct Task: Identifiable {
    let id: UUID
    var title: String
    var duration: TimeInterval
    var remainingDuration: TimeInterval?
    var status: TaskStatus
    var completedAt: Date?
    
    init(title: String, duration: TimeInterval) {
        self.id = UUID()
        self.title = title
        self.duration = duration
        self.status = .notStarted
    }
}

enum TaskStatus: String {
    case notStarted
    case inProgress
    case completed
    case paused
} 