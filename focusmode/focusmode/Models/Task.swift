import Foundation

struct Task: Identifiable, Equatable {
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
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.duration == rhs.duration &&
        lhs.remainingDuration == rhs.remainingDuration &&
        lhs.status == rhs.status &&
        lhs.completedAt == rhs.completedAt
    }
}

enum TaskStatus: String, Equatable {
    case notStarted
    case inProgress
    case completed
    case paused
} 