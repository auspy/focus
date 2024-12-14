import CoreData

extension PersistenceController {
    static func createPreviewTasks() -> [TaskEntity] {
        let context = preview.container.viewContext
        
        let task1 = TaskEntity(context: context)
        task1.id = UUID().uuidString
        task1.title = "Sample Task 1"
        task1.duration = 1500 // 25 minutes
        task1.status = TaskStatus.notStarted.rawValue
        task1.createdAt = Date()
        task1.orderIndex = 0
        
        let task2 = TaskEntity(context: context)
        task2.id = UUID().uuidString
        task2.title = "Sample Task 2"
        task2.duration = 3000 // 50 minutes
        task2.status = TaskStatus.notStarted.rawValue
        task2.createdAt = Date()
        task2.orderIndex = 1
        
        try? context.save()
        
        return [task1, task2]
    }
} 