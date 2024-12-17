import CoreData
import Foundation

protocol TaskRepository {
    func fetchTasks() -> [Task]
    func saveTask(_ task: Task)
    func deleteTask(id: String)
    func updateTaskOrder(tasks: [Task])
    func updateTaskRemainingDuration(id: String, duration: TimeInterval)
    func updateTaskElapsedTime(id: String, elapsedTime: TimeInterval)
    func getTask(by id: String) -> Task?
}

class CoreDataTaskRepository: TaskRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Fetch Tasks
    func fetchTasks() -> [Task] {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.orderIndex, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { mapToTask($0) }
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Save Task
    func saveTask(_ task: Task) {
        // Check if task already exists
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", task.id)
        
        do {
            let results = try context.fetch(request)
            let entity: TaskEntity
            
            if let existingEntity = results.first {
                // Update existing entity
                entity = existingEntity
            } else {
                // Create new entity with unique ID
                entity = TaskEntity(context: context)
                var uniqueId = task.id
                while !isIdUnique(uniqueId) {
                    uniqueId = UUID().uuidString
                }
                entity.id = uniqueId
            }
            
            updateTaskEntity(entity, with: task)
            try context.save()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(id: String) {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            if let taskToDelete = results.first {
                context.delete(taskToDelete)
                try context.save()
            }
        } catch {
            print("Error deleting task: \(error)")
        }
    }
    
    // MARK: - Update Task Order
    func updateTaskOrder(tasks: [Task]) {
        for (index, task) in tasks.enumerated() {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "id == %@", task.id)
            
            do {
                let results = try context.fetch(request)
                if let entity = results.first {
                    entity.orderIndex = Int32(index)
                }
            } catch {
                print("Error updating task order: \(error)")
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving task order: \(error)")
        }
    }
    
    // MARK: - Update Remaining Duration
    func updateTaskRemainingDuration(id: String, duration: TimeInterval) {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.remainingDuration = duration
                try context.save()
            }
        } catch {
            print("Error updating remaining duration: \(error)")
        }
    }
    
    // MARK: - Update Elapsed Time
    func updateTaskElapsedTime(id: String, elapsedTime: TimeInterval) {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.duration = elapsedTime  // For stopwatch, duration is elapsed time
                entity.remainingDuration = 0.0 // Instead of nil, use 0.0 for stopwatch
                try context.save()
            }
        } catch {
            print("Error updating elapsed time: \(error)")
        }
    }
    
    // MARK: - Get Task by ID
    func getTask(by id: String) -> Task? {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            return results.first.map { mapToTask($0) }
        } catch {
            print("Error fetching task by id: \(error)")
            return nil
        }
    }
    
    // MARK: - Mapping Helpers
    private func mapToTask(_ entity: TaskEntity) -> Task {
        var task = Task(
            id: entity.id ?? UUID().uuidString,
            title: entity.title ?? "",
            duration: entity.duration,
            status: TaskStatus(rawValue: entity.status ?? "") ?? .notStarted,
            timingMode: TimingMode(rawValue: entity.timingMode ?? "timer") ?? .timer,
            elapsedTime: entity.timingMode == "stopwatch" ? entity.duration : 0
        )
        
        // Only set remainingDuration for timer mode
        if entity.timingMode == "timer" {
            task.remainingDuration = entity.remainingDuration ?? entity.duration
        }
        task.completedAt = entity.completedAt
        return task
    }
    
    private func updateTaskEntity(_ entity: TaskEntity, with task: Task) {
        entity.id = task.id
        entity.title = task.title
        entity.duration = task.duration
        // Only set remainingDuration if it exists
        if let remainingDuration = task.remainingDuration {
            entity.remainingDuration = remainingDuration
        }
        entity.status = task.status.rawValue
        entity.completedAt = task.completedAt
        entity.createdAt = Date()
        entity.timingMode = task.timingMode.rawValue
        
        // Get the highest order index and add 1
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.orderIndex, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            let highestIndex = results.first?.orderIndex ?? -1
            entity.orderIndex = highestIndex + 1
        } catch {
            print("Error getting highest order index: \(error)")
            entity.orderIndex = 0
        }
    }
    
    // Add this function to check for ID existence
    private func isIdUnique(_ id: String) -> Bool {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let count = try context.count(for: request)
            return count == 0
        } catch {
            print("Error checking ID uniqueness: \(error)")
            return false
        }
    }
} 