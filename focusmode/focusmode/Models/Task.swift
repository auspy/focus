import Foundation

struct Task: Identifiable, Equatable {
    let id: String
    var title: String
    var duration: TimeInterval
    var remainingDuration: TimeInterval?
    var status: TaskStatus
    var completedAt: Date?
    
    init(title: String, duration: TimeInterval) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 0...999999)
        self.id = "\(timestamp)-\(random)"
        self.title = title
        self.duration = duration
        self.status = .notStarted
    }
    
    init(id: String, title: String, duration: TimeInterval, status: TaskStatus = .notStarted) {
        self.id = id
        self.title = title
        self.duration = duration
        self.status = status
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