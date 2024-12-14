import Foundation

class TaskManager: ObservableObject {
    static let shared = TaskManager()
    
    @Published private(set) var currentTask: Task?
    @Published var tasks: [Task] = []
    @Published private(set) var isWorking = false
    
    private let repository: TaskRepository
    
    init(repository: TaskRepository? = nil) {
        self.repository = repository ?? CoreDataTaskRepository(context: PersistenceController.shared.container.viewContext)
        loadTasks()
    }
    
    // MARK: - Persistence
    private func loadTasks() {
        tasks = repository.fetchTasks()
    }
    
    private func saveChanges() {
        repository.updateTaskOrder(tasks: tasks)
    }
    
    func addTask(title: String, duration: TimeInterval) {
        let task = Task(title: title, duration: duration)
        if !tasks.contains(where: { $0.id == task.id }) {
            tasks.append(task)
            repository.saveTask(task)
            saveChanges()
        } else {
            print("Warning: Attempted to add task with duplicate ID")
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        repository.deleteTask(id: task.id)
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
        repository.updateTaskRemainingDuration(id: currentTaskId, duration: duration)
    }
    
    func toggleWorkingState() {
        isWorking.toggle()
        
        // Update task status
        if var task = currentTask {
            task.status = isWorking ? .inProgress : .paused
            // Update in repository
            repository.saveTask(task)
            currentTask = task
        }
        
        NotificationCenter.default.post(
            name: isWorking ? .taskStarted : .taskPaused,
            object: nil,
            userInfo: ["task": currentTask as Any]
        )
    }

    func closeWorkingState() {
        isWorking = false
        currentTask = nil
    }
    
    func startTask(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .inProgress
        currentTask = updatedTask
        isWorking = true
        
        // Update task status in repository
        repository.saveTask(updatedTask)
        
        NotificationCenter.default.post(
            name: .taskStarted,
            object: nil,
            userInfo: ["task": updatedTask]
        )
    }
    
    func completeCurrentTask() {
        guard var currentTask = currentTask else { return }
        
        // Update completion time and status
        currentTask.completedAt = Date()
        currentTask.status = .completed
        
        // Remove from active tasks list
        if let index = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            tasks.remove(at: index)
            // Delete from persistent storage since it's completed
            repository.deleteTask(id: currentTask.id)
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
            NotificationCenter.default.post(name: .allTasksCompleted, object: nil)
        }
        
        objectWillChange.send()
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
            
            // Update status of old task
            var oldTask = currentTask
            oldTask.status = .paused
            repository.saveTask(oldTask)
            
            // Pause current task
            isWorking = false
            
            // Switch to new top task
            self.currentTask = newTopTask
            
            NotificationCenter.default.post(
                name: .taskSwitched,
                object: nil,
                userInfo: [
                    "oldTask": oldTask,
                    "newTask": newTopTask
                ]
            )
        }
        
        // Update order in repository
        saveChanges()
    }
    
    func addTime(minutes: Int) {
        guard var currentTask = currentTask else { return }
        let additionalSeconds = TimeInterval(minutes * 60)
        currentTask.duration += additionalSeconds
        
        // Also update remaining duration
        if let remainingDuration = currentTask.remainingDuration {
            currentTask.remainingDuration = remainingDuration + additionalSeconds
        } else {
            currentTask.remainingDuration = currentTask.duration
        }
        
        // Update in tasks array
        if let index = tasks.firstIndex(where: { $0.id == currentTask.id }) {
            tasks[index] = currentTask
        }
        
        // Update in repository
        repository.saveTask(currentTask)
        
        // Update current task reference
        self.currentTask = currentTask
        
        // Notify observers
        NotificationCenter.default.post(
            name: .taskTimeAdded,
            object: nil,
            userInfo: ["task": currentTask, "addedSeconds": additionalSeconds]
        )
        
        objectWillChange.send()
    }
}

extension Notification.Name {
    static let taskStarted = Notification.Name("taskStarted")
    static let taskPaused = Notification.Name("taskPaused")
    static let taskSwitched = Notification.Name("taskSwitched")
    static let allTasksCompleted = Notification.Name("allTasksCompleted")
    static let taskTimeAdded = Notification.Name("taskTimeAdded")
} 