//
//  ContentView.swift
//  focusmode
//
//  Created by Kshetez Vinayak on 13/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager.shared
    
    var body: some View {
        VStack {
            startButton
            TaskListView()
                .opacity(taskManager.isWorking ? 0.6 : 1.0)
        }
        .padding()
    }
    
    private var startButton: some View {
        Button(action: {
            if !taskManager.isWorking {
                startWorkSession()
            } else {
                taskManager.toggleWorkingState()
            }
        }) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    if taskManager.isWorking {
                        WaveProgressView(
                            progress: calculateTaskProgress(taskManager.currentTask),
                            color: Color.accentColor
                        )
                    }
                    
                    HStack {
                        Image(systemName: taskManager.isWorking ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 24))
                        Text(taskManager.isWorking ? "Working..." : "Start Working")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                }
            }
        }
        .frame(height: 44)
        .background(taskManager.isWorking ? Color.gray.opacity(0.3) : Color.accentColor)
        .cornerRadius(10)
        .buttonStyle(PlainButtonStyle())
        .disabled(taskManager.tasks.isEmpty)
    }
    
    private func startWorkSession() {
        guard let firstTask = taskManager.tasks.first else { return }
        taskManager.startTask(firstTask)
        WindowManager.shared.showFloatingTimer(for: firstTask)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let taskCompleted = Notification.Name("taskCompleted")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
