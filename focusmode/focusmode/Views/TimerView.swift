import SwiftUI

struct TimerView: View {
    @StateObject private var timer = TimerManager()
    let task: Task
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(task.title)
                .font(.headline)
            
            Text(timer.timeString)
                .font(.system(size: 48, weight: .bold))
                .monospacedDigit()
            
            HStack(spacing: 20) {
                Button(timer.isRunning ? "Pause" : "Start") {
                    timer.isRunning ? timer.pause() : timer.start()
                }
                .keyboardShortcut(" ", modifiers: [])
                
                Button("Reset") {
                    timer.reset()
                }
                .disabled(timer.timeRemaining == task.duration)
            }
        }
        .padding()
        .onAppear {
            timer.setup(duration: task.duration) {
                onComplete()
            }
        }
    }
}

class TimerManager: ObservableObject {
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var isRunning = false
    private var timer: Timer?
    private var completion: (() -> Void)?
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setup(duration: TimeInterval, completion: @escaping () -> Void) {
        self.timeRemaining = duration
        self.completion = completion
    }
    
    func start() {
        guard !isRunning && timeRemaining > 0 else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = 0
    }
    
    func complete() {
        timeRemaining = 0
        completion?()
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            complete()
            return
        }
        timeRemaining -= 1
    }
} 