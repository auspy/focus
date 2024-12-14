import SwiftUI

enum ProgressStyle: CaseIterable {
    case wave
    case linear
    
    var name: String {
        switch self {
        case .wave: return "Wave"
        case .linear: return "Linear"
        }
    }
    
    var icon: String {
        switch self {
        case .wave: return "waveform"
        case .linear: return "line.horizontal.3"
        }
    }
}

struct ProgressStylePicker: View {
    @Binding var selectedStyle: ProgressStyle
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(ProgressStyle.allCases, id: \.self) { style in
                Button(action: {
                    selectedStyle = style
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: style.icon)
                            .font(.system(size: 20))
                        Text(style.name)
                            .font(.caption)
                    }
                    .frame(width: 60, height: 60)
                    .background(selectedStyle == style ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

private struct ControlButtons: View {
    let taskManager: TaskManager
    let completeTask: () -> Void
    let timerDisplay: String
    
    var body: some View {
        HStack(spacing: 8) {
            // +5 button
            Button(action: {
                taskManager.addTime(minutes: 5)
            }) {
                HStack(spacing: 2) {
                    Text("+5m")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.background)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1)
                        .background(.primary)
                        .cornerRadius(4)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { isHovered in
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            // Timer display
            Text(timerDisplay)
                .monospacedDigit()
            
            // Play/Pause button
            Button(action: {
                taskManager.toggleWorkingState()
            }) {
                Image(systemName: taskManager.isWorking ? "pause.fill" : "play.fill")
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { isHovered in
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            // Tick button
            Button(action: completeTask) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { isHovered in
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

struct FloatingTimerView: View {
    @ObservedObject var taskManager: TaskManager
    @Binding var progressStyle: ProgressStyle
    @State private var isHovering = false
    @State private var remainingSeconds: Int
    @State private var waveOffset = 0.0
    @State private var showCelebration = false
    
    // Constants for customization
    private let progressColor = Color(hex: "#007AFF") // Apple's default blue
    private let initialSeconds: Int
    
    // Computed property to get current task
    private var currentTask: Task? {
        taskManager.currentTask
    }
    
    // Add computed property to check tasks status
    private var isAllTasksComplete: Bool {
        taskManager.tasks.isEmpty && currentTask == nil
    }
    
    // Add computed property for progress color
    private var currentProgressColor: Color {
        // If less than 10% time remaining, show red
        if progress > 0.9 {
            return .red
        }
        return progressColor
    }
    
    init(task: Task, progressStyle: Binding<ProgressStyle>) {
        self.taskManager = TaskManager.shared  // Initialize taskManager
        self._progressStyle = progressStyle
        let seconds = Int(task.remainingDuration ?? task.duration)
        _remainingSeconds = State(initialValue: seconds)
        self.initialSeconds = Int(task.duration)
    }
    
    private var timerDisplay: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        
        print("Current time breakdown - Hours:", hours, "Minutes:", minutes, "Seconds:", seconds)
        print("Total remaining seconds:", remainingSeconds)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var progress: CGFloat {
        // Calculate progress from 0.0 to 1.0
        let elapsed = initialSeconds - remainingSeconds
        return CGFloat(elapsed) / CGFloat(initialSeconds)
    }
    
    @ViewBuilder
    private func progressView(in geometry: GeometryProxy) -> some View {
        switch progressStyle {
        case .wave:
            WaveProgressView(
                progress: progress,
                color: currentProgressColor,
                isAnimating: taskManager.isWorking
            )
            .frame(height: geometry.size.height)
            .animation(.linear(duration: 2), value: progress)
            
        case .linear:
            currentProgressColor
                .frame(width: geometry.size.width * progress)
                .animation(.linear(duration: 0.1), value: progress)
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    progressView(in: geometry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if showCelebration {
                        CelebrationView(
                            isAllTasksComplete: isAllTasksComplete,
                            taskTitle: currentTask?.title ?? "",
                            onComplete: {
                                showCelebration = false
                                if !isAllTasksComplete {
                                    taskManager.completeCurrentTask()
                                }
                            }
                        )
                    } else {
                        HStack(spacing: 0) {
                            // Text on left
                            Text(currentTask?.title ?? "No Task")
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.leading)
                                // .frame(minWidth: 100)
                            
                            Spacer()
                            
                            // Timer and control button on right
                            HStack(spacing: 12) {
                                if isHovering {
                                    ControlButtons(
                                        taskManager: taskManager,
                                        completeTask: completeTask,
                                        timerDisplay: timerDisplay
                                    )
                                } else {
                                    // Show timer and play button when paused
                                    HStack(spacing: 8) {
                                        Text(timerDisplay)
                                            .monospacedDigit()
                                        
                                        // Always show play button when paused
                                        if !taskManager.isWorking {
                                            Button(action: {
                                                taskManager.toggleWorkingState()
                                            }) {
                                                Image(systemName: "play.fill")
                                                    .foregroundColor(.primary)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .onHover { isHovered in
                                                if isHovered {
                                                    NSCursor.pointingHand.push()
                                                } else {
                                                    NSCursor.pop()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.trailing)
                        }
                    }
                }
            }
        }
        .frame(height: 40)
        .background(Color(NSColor.windowBackgroundColor))
        .onHover { hovering in
            isHovering = hovering
        }
        .onAppear {
            // Initialize state first
            if let task = currentTask {
                remainingSeconds = Int(task.remainingDuration ?? task.duration)
                showCelebration = false
            }
            
            // Start timer after initialization
            startTimer()
            
            if progressStyle == .wave {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    waveOffset = .pi * 2
                }
            }
        }
        .onChange(of: currentTask?.id) { oldValue, newValue in
            // Update when current task changes
            if let task = currentTask {
                remainingSeconds = Int(task.remainingDuration ?? task.duration)
                // Reset celebration state when switching to a new task
                showCelebration = false
            }
        }
        .onChange(of: taskManager.tasks) { oldTasks, newTasks in
            // If tasks were added (list is not empty), reset celebration
            if !newTasks.isEmpty {
                showCelebration = false
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard taskManager.isWorking else { return }
            
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                // Update task remaining duration through TaskManager
                taskManager.updateTaskRemainingDuration(TimeInterval(remainingSeconds))
            } else {
                timer.invalidate()
                taskManager.completeCurrentTask()
            }
        }
        
        // Listen for task switches
        NotificationCenter.default.addObserver(
            forName: .taskSwitched,
            object: nil,
            queue: .main
        ) { [self] notification in
            guard let userInfo = notification.userInfo,
                  let newTask = userInfo["newTask"] as? Task else { return }
            
            // Update timer with new task's remaining duration
            remainingSeconds = Int(newTask.remainingDuration ?? newTask.duration)
            // Only reset celebration, isAllTasksComplete is now computed
            showCelebration = false
        }
        
        // Listen for all tasks completed
        NotificationCenter.default.addObserver(
            forName: .allTasksCompleted,
            object: nil,
            queue: .main
        ) { [self] _ in
            remainingSeconds = 0
            showCelebration = true
        }
        
        // Listen for time additions
        NotificationCenter.default.addObserver(
            forName: .taskTimeAdded,
            object: nil,
            queue: .main
        ) { [self] notification in
            guard let userInfo = notification.userInfo,
                  let addedSeconds = userInfo["addedSeconds"] as? TimeInterval else { return }
            
            remainingSeconds += Int(addedSeconds)
        }
    }
    
    private func completeTask() {
        guard taskManager.currentTask != nil else { return }
        showCelebration = true
    }
}

// Preview provider for SwiftUI canvas
struct FloatingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProgressStylePicker(selectedStyle: .constant(.wave))
                .previewLayout(.sizeThatFits)
            
            VStack {
                FloatingTimerView(task: Task(title: "Wave Style", duration: 25), 
                                progressStyle: .constant(.wave))
                FloatingTimerView(task: Task(title: "Linear Style", duration: 25), 
                                progressStyle: .constant(.linear))
            }
        }
    }
}

// Add this extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(hex: Int) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
} 