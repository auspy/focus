import Foundation

class TaskManager: ObservableObject {
    static let shared = TaskManager()
    
    @Published private(set) var tasks: [Task] = []
    @Published var currentTask: Task?
    
    // Make init private for singleton pattern
    private init() {}
    
    func addTask(title: String, duration: TimeInterval) {
        let task = Task(title: title, duration: duration)
        tasks.append(task)
    }
    
    func startTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].status = .inProgress
        currentTask = tasks[index]
        
        // Show floating timer window
        WindowManager.shared.showFloatingTimer(for: tasks[index])
    }
    
    func completeTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].status = .completed
        tasks[index].completedAt = Date()
        if currentTask?.id == task.id {
            currentTask = nil
            WindowManager.shared.closeFloatingWindow()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        if currentTask?.id == task.id {
            currentTask = nil
            WindowManager.shared.closeFloatingWindow()
        }
    }
} 