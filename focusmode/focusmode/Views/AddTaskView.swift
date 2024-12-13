import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var duration: Double = 25 // Default 25 minutes
    let onAdd: (String, TimeInterval) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $title)
                
                Stepper(value: $duration, in: 1...120) {
                    Text("\(Int(duration)) minutes")
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(title, duration * 60) // Convert minutes to seconds
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 