import SwiftUI

struct TaskListView: View {
    @StateObject private var taskManager = TaskManager.shared
    @State private var isAddingTask = false
    
    var body: some View {
        VStack {
            List {
                ForEach(taskManager.tasks) { task in
                    TaskRow(task: task, 
                           onStart: {
                               taskManager.startTask(task)
                           },
                           onDelete: {
                               taskManager.deleteTask(task)
                           })
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
            }
            
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
    let onStart: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(formatDuration(task.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if task.status == .notStarted {
                    Button("Start Working") {
                        onStart()
                    }
                } else {
                    Text(task.status.rawValue)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Delete Task")
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
} 