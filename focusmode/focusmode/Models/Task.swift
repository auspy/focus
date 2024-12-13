import Foundation

struct Task: Identifiable {
    let id: UUID = UUID()
    var title: String
    var description: String?
    var duration: TimeInterval
    var status: TaskStatus
    var createdAt: Date = Date()
    var completedAt: Date?
    var colorCode: String
    
    init(title: String, duration: TimeInterval, colorCode: String = "#007AFF") {
        self.title = title
        self.duration = duration
        self.status = .notStarted
        self.colorCode = colorCode
    }
}

enum TaskStatus: String {
    case notStarted
    case inProgress
    case completed
    case paused
} 