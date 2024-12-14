import SwiftUI
import ConfettiSwiftUI

struct CelebrationView: View {
    @State private var counter = 0
    let isAllTasksComplete: Bool
    let taskTitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkmark on left
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.green)
            
            // Text in middle
            VStack(alignment: .leading, spacing: 2) {
                if isAllTasksComplete {
                    Text("All Tasks Complete! 🎉")
                        .font(.headline)
                    
                    Text("Great job today!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } 
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 40) // Same height as timer view
        .background(Color(NSColor.windowBackgroundColor))
        .confettiCannon(counter: $counter, 
                       num: isAllTasksComplete ? 50 : 30,
                       openingAngle: Angle(degrees: 0),
                       closingAngle: Angle(degrees: 360),
                       radius: 200)
        .onAppear {
            counter += 1
        }
    }
}

struct CelebrationView_Previews: PreviewProvider {
    static var previews: some View {
        CelebrationView(isAllTasksComplete: true, taskTitle: "Sample Task")
        CelebrationView(isAllTasksComplete: false, taskTitle: "Sample Task")
    }
} 