import XCTest
@testable import focusmode

final class TaskManagerTests: XCTestCase {
    var persistenceController: PersistenceController!
    var taskManager: TaskManager!
    var repository: TaskRepository!
    
    override func setUp() {
        super.setUp()
        // Create a fresh in-memory store for each test
        persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        
        // Clear any existing data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TaskEntity")
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                if let managedObject = object as? NSManagedObject {
                    context.delete(managedObject)
                }
            }
            try context.save()
        } catch {
            print("Error clearing test data: \(error)")
        }
        
        // Create fresh instances
        repository = CoreDataTaskRepository(context: context)
        taskManager = TaskManager(repository: repository)
    }
    
    override func tearDown() {
        // Clean up
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TaskEntity")
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                if let managedObject = object as? NSManagedObject {
                    context.delete(managedObject)
                }
            }
            try context.save()
        } catch {
            print("Error cleaning up test data: \(error)")
        }
        
        persistenceController = nil
        taskManager = nil
        repository = nil
        super.tearDown()
    }
    
    // MARK: - Task Creation Tests
    func testAddTask() {
        // Given
        let title = "Test Task"
        let duration: TimeInterval = 1500
        
        // When
        taskManager.addTask(title: title, duration: duration)
        
        // Then
        XCTAssertEqual(taskManager.tasks.count, 1, "Should have exactly one task")
        
        let task = taskManager.tasks.first
        XCTAssertNotNil(task, "Task should exist")
        XCTAssertEqual(task?.title, title, "Task title should match")
        XCTAssertEqual(task?.duration, duration, "Task duration should match")
        
        // Verify persistence
        let savedTasks = repository.fetchTasks()
        XCTAssertEqual(savedTasks.count, 1, "Should have exactly one saved task")
        XCTAssertEqual(savedTasks.first?.title, title, "Saved task title should match")
    }
    
    // MARK: - Task State Tests
    func testTaskStateTransitions() {
        // Given
        let task = Task(title: "Test Task", duration: 1500)
        taskManager.addTask(title: task.title, duration: task.duration)
        
        // When - Start task
        taskManager.startTask(taskManager.tasks[0])
        
        // Then
        XCTAssertEqual(taskManager.currentTask?.status, .inProgress)
        XCTAssertTrue(taskManager.isWorking)
        
        // When - Pause task
        taskManager.toggleWorkingState()
        
        // Then
        XCTAssertEqual(taskManager.currentTask?.status, .paused)
        XCTAssertFalse(taskManager.isWorking)
        
        // Verify persistence
        let savedTask = repository.getTask(by: taskManager.currentTask!.id)
        XCTAssertEqual(savedTask?.status, .paused)
    }
    
    // MARK: - Task Completion Tests
    func testTaskCompletion() {
        // Given
        taskManager.addTask(title: "Task 1", duration: 1500)
        taskManager.addTask(title: "Task 2", duration: 1500)
        taskManager.startTask(taskManager.tasks[0])
        
        // When
        taskManager.completeCurrentTask()
        
        // Then
        XCTAssertEqual(taskManager.tasks.count, 1)
        XCTAssertEqual(taskManager.tasks[0].title, "Task 2")
        
        // Verify first task is removed from persistence
        let savedTasks = repository.fetchTasks()
        XCTAssertEqual(savedTasks.count, 1)
        XCTAssertEqual(savedTasks[0].title, "Task 2")
    }
    
    // MARK: - Task Ordering Tests
    func testTaskReordering() {
        // Given
        taskManager.addTask(title: "Task 1", duration: 1500)
        taskManager.addTask(title: "Task 2", duration: 1500)
        taskManager.addTask(title: "Task 3", duration: 1500)
        
        // When
        taskManager.moveTask(from: IndexSet(integer: 2), to: 0)
        
        // Then
        XCTAssertEqual(taskManager.tasks[0].title, "Task 3")
        XCTAssertEqual(taskManager.tasks[1].title, "Task 1")
        XCTAssertEqual(taskManager.tasks[2].title, "Task 2")
        
        // Verify persistence
        let savedTasks = repository.fetchTasks()
        XCTAssertEqual(savedTasks[0].title, "Task 3")
        XCTAssertEqual(savedTasks[1].title, "Task 1")
        XCTAssertEqual(savedTasks[2].title, "Task 2")
    }
    
    // MARK: - Duration Update Tests
    func testRemainingDurationUpdate() {
        // Given
        taskManager.addTask(title: "Test Task", duration: 1500)
        taskManager.startTask(taskManager.tasks[0])
        
        // When
        let newDuration: TimeInterval = 1000
        taskManager.updateTaskRemainingDuration(newDuration)
        
        // Then
        XCTAssertEqual(taskManager.currentTask?.remainingDuration, newDuration)
        
        // Verify persistence
        let savedTask = repository.getTask(by: taskManager.currentTask!.id)
        XCTAssertEqual(savedTask?.remainingDuration, newDuration)
    }
    
    // MARK: - Unique Task IDs Test
    func testUniqueTaskIds() {
        // Given
        taskManager.addTask(title: "Task 1", duration: 1500)
        taskManager.addTask(title: "Task 2", duration: 1500)
        taskManager.addTask(title: "Task 3", duration: 1500)
        
        // Then
        let ids = taskManager.tasks.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "Task IDs must be unique")
    }
} 