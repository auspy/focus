import Foundation

class TaskManager: ObservableObject {
    static let shared = TaskManager()
    
    @Published private(set) var currentTask: Task?
    @Published var tasks: [Task] = []
    @Published private(set) var isWorking = false
    
    private init() {
        loadTasks()
    }
    
    func toggleWorkingState() {
        isWorking.toggle()
        // Notify state change
        NotificationCenter.default.post(
            name: isWorking ? .taskStarted : .taskPaused,
            object: nil,
            userInfo: ["task": currentTask as Any]
        )
    }
    
    func startTask(_ task: Task) {
        currentTask = task
        isWorking = true
        // Notify floating timer to start
        NotificationCenter.default.post(
            name: .taskStarted,
            object: nil,
            userInfo: ["task": task]
        )
    }
    
    func completeCurrentTask() {
        guard let task = currentTask else { return }
        
        // Update task status
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = .completed
            tasks[index].completedAt = Date()
        }
        
        currentTask = nil
        
        // Notify completion
        NotificationCenter.default.post(name: .taskCompleted, object: nil)
        
        // Save changes
        saveChanges()
    }
    
    func addTask(title: String, duration: TimeInterval) {
        let task = Task(title: title, duration: duration)
        tasks.append(task)
        saveChanges()
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        if currentTask?.id == task.id {
            currentTask = nil
            WindowManager.shared.closeFloatingWindow()
        }
        saveChanges()
    }
    
    // MARK: - Persistence
    private func loadTasks() {
        // TODO: Replace with actual persistence implementation
        // For now, just initialize with empty array
        tasks = []
    }
    
    private func saveChanges() {
        // TODO: Replace with actual persistence implementation
        // For now, just print for debugging
        print("Saving tasks: \(tasks)")
    }
}

extension Notification.Name {
    static let taskStarted = Notification.Name("taskStarted")
    static let taskPaused = Notification.Name("taskPaused")
} 