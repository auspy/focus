import XCTest
@testable import focusmode

class TaskManagerTests: XCTestCase {
    // existing tests...
    
    func testAddTime() {
        let taskManager = TaskManager()
        let task = Task(title: "Test Task", duration: 1500) // 25 minutes
        taskManager.currentTask = task
        
        taskManager.addTime(minutes: 5)
        
        XCTAssertEqual(task.duration, 1800) // 30 minutes
    }
} 