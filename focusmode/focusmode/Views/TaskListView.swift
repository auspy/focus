import SwiftUI

struct TaskListView: View {
    @StateObject private var taskManager = TaskManager.shared
    @State private var isAddingTask = false
    
    var body: some View {
        VStack {
            List {
                ForEach(taskManager.tasks) { task in
                    TaskRow(
                        task: task,
                        isCurrentTask: taskManager.currentTask?.id == task.id,
                        onDelete: {
                            taskManager.deleteTask(task)
                        }
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            taskManager.deleteTask(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            taskManager.deleteTask(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: taskManager.moveTask)
            }
            .listStyle(PlainListStyle())
            
            Button("Add Task") {
                isAddingTask = true
            }
        }
        .sheet(isPresented: $isAddingTask) {
            AddTaskView { title, duration in
                taskManager.addTask(title: title, duration: duration)
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let isCurrentTask: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(formatTime(task.remainingDuration ?? task.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCurrentTask {
                Text("Current Task")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Delete Task")
        }
        .padding(.vertical, 8)
        .opacity(isCurrentTask ? 1.0 : 0.6)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d remaining", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d remaining", minutes, seconds)
        } else {
            return "\(seconds)s remaining"
        }
    }
} 