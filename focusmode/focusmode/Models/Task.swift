import Foundation

enum TimingMode: String, Codable {
    case timer
    case stopwatch
}

struct Task: Identifiable, Equatable {
    let id: String
    var title: String
    var duration: TimeInterval
    var remainingDuration: TimeInterval?
    var status: TaskStatus
    var completedAt: Date?
    var timingMode: TimingMode
    var elapsedTime: TimeInterval
    
    init(title: String, duration: TimeInterval, timingMode: TimingMode = .timer) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 0...999999)
        self.id = "\(timestamp)-\(random)"
        self.title = title
        self.duration = duration
        self.status = .notStarted
        self.timingMode = timingMode
        self.elapsedTime = 0
        
        if timingMode == .timer {
            self.remainingDuration = duration
        }
    }
    
    init(id: String, title: String, duration: TimeInterval, status: TaskStatus = .notStarted, timingMode: TimingMode = .timer, elapsedTime: TimeInterval = 0) {
        self.id = id
        self.title = title
        self.duration = duration
        self.status = status
        self.timingMode = timingMode
        self.elapsedTime = elapsedTime
        
        if timingMode == .timer {
            self.remainingDuration = duration
        }
    }
    
    mutating func updateElapsedTime(_ elapsed: TimeInterval) {
        if timingMode == .stopwatch {
            self.elapsedTime = elapsed
            self.duration = elapsed
        }
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.duration == rhs.duration &&
        lhs.remainingDuration == rhs.remainingDuration &&
        lhs.status == rhs.status &&
        lhs.completedAt == rhs.completedAt &&
        lhs.timingMode == rhs.timingMode &&
        lhs.elapsedTime == rhs.elapsedTime
    }
}

enum TaskStatus: String, Equatable {
    case notStarted
    case inProgress
    case completed
    case paused
} 