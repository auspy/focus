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
        guard var currentTask = currentTask else { return }
        
        // Update completion time
        currentTask.completedAt = Date()
        
        // Remove from active tasks list
        if let index = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            tasks.remove(at: index)
        }
        
        // Stop working state first
        isWorking = false
        
        // Move to next task if available
        if !tasks.isEmpty {
            self.currentTask = tasks[0]
            NotificationCenter.default.post(
                name: .taskSwitched,
                object: nil,
                userInfo: ["newTask": tasks[0]]
            )
        } else {
            self.currentTask = nil
            // Notify that all tasks are completed
            NotificationCenter.default.post(name: .allTasksCompleted, object: nil)
        }
        
        // Notify observers about task completion
        objectWillChange.send()
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
        }
        saveChanges()
    }
    
    func updateTaskRemainingDuration(_ duration: TimeInterval) {
        guard let currentTaskId = currentTask?.id,
              let index = tasks.firstIndex(where: { $0.id == currentTaskId }) else { return }
        
        tasks[index].remainingDuration = duration
        currentTask = tasks[index]
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        // Store the current top task before moving
        let oldTopTaskId = tasks.first?.id
        
        // Perform the move
        tasks.move(fromOffsets: source, toOffset: destination)
        
        // Check if top task changed and we're currently working
        if isWorking,
           let newTopTask = tasks.first,
           oldTopTaskId != newTopTask.id,
           let currentTask = currentTask {
            
            // Store progress of current task before switching
            updateTaskRemainingDuration(TimeInterval(currentTask.remainingDuration ?? currentTask.duration))
            
            // Pause current task
            isWorking = false
            
            // Switch to new top task
            self.currentTask = newTopTask
            
            // Notify about task switch
            NotificationCenter.default.post(
                name: .taskSwitched,
                object: nil,
                userInfo: [
                    "oldTask": currentTask,
                    "newTask": newTopTask
                ]
            )
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
    static let taskSwitched = Notification.Name("taskSwitched")
    static let allTasksCompleted = Notification.Name("allTasksCompleted")
} 