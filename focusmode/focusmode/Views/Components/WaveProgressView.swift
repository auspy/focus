import SwiftUI

struct WaveProgressView: View {
    let progress: CGFloat
    let color: Color
    let isAnimating: Bool
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            WaveShape(
                progress: progress,
                waveHeight: 4,
                offset: phase
            )
            .fill(color)
            .frame(width: geometry.size.width)
        }
        .onAppear {
            withAnimation(isAnimating ? .linear(duration: 2).repeatForever(autoreverses: false) : nil) {
                phase = .pi * 2
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            withAnimation(newValue ? .linear(duration: 2).repeatForever(autoreverses: false) : nil) {
                phase = .pi * 2
            }
        }
    }
}

struct WaveShape: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let progressWidth = width * progress
        
        path.move(to: .zero)
        
        // Draw wave
        for x in stride(from: 0, through: progressWidth, by: 2) {
            let relativeX = x / 20 // Adjust wave frequency
            let y = sin(relativeX + offset) * waveHeight
            path.addLine(to: CGPoint(x: x, y: height/2 + y))
        }
        
        // Complete the shape
        path.addLine(to: CGPoint(x: progressWidth, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// Helper function for progress calculation
func calculateTaskProgress(_ task: Task?) -> CGFloat {
    guard let task = task else { return 0 }
    let totalDuration = task.duration
    let remainingDuration = task.remainingDuration ?? totalDuration
    return 1 - (CGFloat(remainingDuration) / CGFloat(totalDuration))
} 