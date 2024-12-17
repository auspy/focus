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
                        .fixedSize()
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
                .fixedSize()
            
          
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

              // Play/Pause button
            Button(action: {
                taskManager.toggleWorkingState()
            }) {
                Image(systemName: taskManager.isWorking ? "pause.fill" : "play.fill")
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(taskManager.tasks.isEmpty || taskManager.currentTask == nil || taskManager.currentTask?.title == nil || taskManager.currentTask?.title == "No Task" || taskManager.currentTask?.remainingDuration == nil || (taskManager.currentTask?.remainingDuration ?? 0) <= 0)
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

// Add TimerStateManager class before FloatingTimerView
class TimerStateManager: ObservableObject {
    var taskSwitchToken: NSObjectProtocol?
    var tasksCompletedToken: NSObjectProtocol?
    var timeAddedToken: NSObjectProtocol?
    var timerInstance: Timer?
    
    func cleanup() {
        timerInstance?.invalidate()
        timerInstance = nil
        
        if let token = taskSwitchToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = tasksCompletedToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = timeAddedToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    deinit {
        cleanup()
    }
}

struct FloatingTimerView: View {
    @ObservedObject var taskManager: TaskManager
    @Binding var progressStyle: ProgressStyle
    @StateObject private var timerState = TimerStateManager()
    @State private var isHovering = false
    @State private var remainingSeconds: Int
    @State private var startTimeSeconds: Int
    @State private var totalDuration: Int
    @State private var waveOffset = 0.0
    @State private var showCelebration = false
    @State private var isTimerPaused = false
    @State private var showZeroTimeAlert = false
    
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
        print("[Init] Initial seconds set to:", seconds)
        _remainingSeconds = State(initialValue: seconds)
        _startTimeSeconds = State(initialValue: seconds)
        _totalDuration = State(initialValue: Int(task.duration))
        self.initialSeconds = Int(task.duration)
    }
    
    private var timerDisplay: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        
        print("[TimerDisplay] Current time breakdown - Hours:", hours, "Minutes:", minutes, "Seconds:", seconds)
        print("[TimerDisplay] Total remaining seconds:", remainingSeconds)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var progress: CGFloat {
        guard let task = currentTask else { return 0 }
        let totalDuration = TimeInterval(totalDuration)
        let remainingDuration = TimeInterval(remainingSeconds)
        return 1 - (CGFloat(remainingDuration) / CGFloat(totalDuration))
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
                    if !isAllTasksComplete {
                        progressView(in: geometry)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        HStack(spacing: 0) {
                            // Timer content
                            Text(currentTask?.title ?? "No Task")
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.leading)
                            
                            Spacer()
                            
                            // Timer and control buttons
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
                                            .fixedSize()
                                        
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
                    } else {
                        CelebrationView(
                            isAllTasksComplete: isAllTasksComplete,
                            taskTitle: currentTask?.title ?? ""
                        )
                    }
                }
            }
        }
        .frame(height: 40)
        .background(Color(NSColor.windowBackgroundColor))
        .onHover { hovering in
            isHovering = hovering
        }
        .alert("Timer Completed", isPresented: $showZeroTimeAlert) {
            Button("Complete Task") {
                completeTask()
            }
            Button("Start Again") {
                // Reset timer to initial duration and start
                remainingSeconds = totalDuration
                startTimeSeconds = remainingSeconds
                taskManager.updateTaskRemainingDuration(TimeInterval(remainingSeconds))
                taskManager.toggleWorkingState()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to complete this task or start the timer again?")
        }
        .onAppear {
            // Initialize state first
            if let task = currentTask {
                remainingSeconds = Int(task.remainingDuration ?? task.duration)
                startTimeSeconds = remainingSeconds
                totalDuration = Int(task.duration)
                isTimerPaused = false
            }
            
            // Start timer after initialization
            startTimer()
        }
        .onDisappear {
            timerState.cleanup()
        }
        .onChange(of: currentTask?.id) { oldValue, newValue in
            // Update when current task changes
            if let task = currentTask {
                remainingSeconds = Int(task.remainingDuration ?? task.duration)
                startTimeSeconds = remainingSeconds
                totalDuration = Int(task.duration)
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
        // If time is zero, show confirmation dialog
        if remainingSeconds == 0 {
            showZeroTimeAlert = true
            return
        }
        
        // Cleanup existing timer and observers
        timerState.cleanup()
        
        // Create and retain new timer
        timerState.timerInstance = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // Only update if task is in working state
            guard self.taskManager.isWorking else {
                print("[Timer] Skipped update - task not working")
                return
            }
            
            print("[Timer] Before update - remainingSeconds:", self.remainingSeconds)
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                print("[Timer] After decrement - remainingSeconds:", self.remainingSeconds)
                self.taskManager.updateTaskRemainingDuration(TimeInterval(self.remainingSeconds))
            } else {
                print("[Timer] Timer reached zero - stopping timer")
                self.taskManager.toggleWorkingState() // Stop the timer but don't complete the task
            }
        }
        
        // Listen for task switches
        timerState.taskSwitchToken = NotificationCenter.default.addObserver(
            forName: .taskSwitched,
            object: nil,
            queue: .main
        ) { [self] notification in
            guard let userInfo = notification.userInfo,
                  let newTask = userInfo["newTask"] as? Task,
                  !showCelebration else {
                print("[TaskSwitch] Switch ignored - celebration showing or invalid data")
                return
            }
            
            print("[TaskSwitch] Updating remainingSeconds from:", remainingSeconds)
            remainingSeconds = Int(newTask.remainingDuration ?? newTask.duration)
            print("[TaskSwitch] Updated remainingSeconds to:", remainingSeconds)
            startTimeSeconds = remainingSeconds
            totalDuration = Int(newTask.duration)
        }
        
        // Listen for all tasks completed
        timerState.tasksCompletedToken = NotificationCenter.default.addObserver(
            forName: .allTasksCompleted,
            object: nil,
            queue: .main
        ) { [self] _ in
            // Only reset timer if this is actually the current task being completed
            guard taskManager.tasks.isEmpty && currentTask == nil else { return }
            remainingSeconds = 0
        }
        
        // Listen for time additions
        timerState.timeAddedToken = NotificationCenter.default.addObserver(
            forName: .taskTimeAdded,
            object: nil,
            queue: .main
        ) { [self] notification in
            guard let userInfo = notification.userInfo,
                  let addedSeconds = userInfo["addedSeconds"] as? TimeInterval,
                  !showCelebration else { return }
            
            remainingSeconds += Int(addedSeconds)
            totalDuration += Int(addedSeconds)
        }
    }
    
    private func completeTask() {
        
        // 1. Show celebration immediately
        showCelebration = true

        // 2. Complete the current task and await for the update
        taskManager.completeCurrentTask()

        // 3. Hide celebration after task is updated, but only if there are remaining tasks
        // Keep showing celebration for a moment after task completion
        if !taskManager.tasks.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.showCelebration = false
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
