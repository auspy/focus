import SwiftUI

struct TimePreviewView: View {
    let duration: Double // in minutes
    
    var formattedTime: String {
        let hours = Int(duration) / 60
        let minutes = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:00", hours, minutes)
        }
        return String(format: "%02d:00", minutes)
    }
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: 32, weight: .medium, design: .rounded))
            .foregroundColor(AppColors.primary)
            .padding(.bottom, 8)
    }
}

struct DurationInputView: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    
    var body: some View {
        HStack(spacing: 4) {
            // Hours
            HStack(spacing: 2) {
                TextField("0", value: $hours, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 40)
                    .multilineTextAlignment(.trailing)
                Text("h")
                    .foregroundColor(AppColors.secondaryText)
                    .font(.system(size: 13))
            }
            
            // Minutes
            HStack(spacing: 2) {
                TextField("0", value: $minutes, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 40)
                    .multilineTextAlignment(.trailing)
                Text("m")
                    .foregroundColor(AppColors.secondaryText)
                    .font(.system(size: 13))
            }
        }
    }
}

struct TaskInputSection: View {
    @Binding var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Label:")
                .foregroundColor(AppColors.secondaryText)
                .font(.system(size: 13))
            TextField("Task Title", text: $title)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct DurationPreset: Identifiable {
    let id = UUID()
    let hours: Int
    let minutes: Int
    
    var totalMinutes: Int {
        hours * 60 + minutes
    }
}

struct DurationSection: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    let commonDurations: [DurationPreset]
    
    private var minutePresets: [DurationPreset] {
        commonDurations.filter { $0.hours == 0 }
    }
    
    private var hourPresets: [DurationPreset] {
        commonDurations.filter { $0.hours > 0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration:")
                .foregroundColor(AppColors.secondaryText)
                .font(.system(size: 13))
            
            DurationInputView(hours: $hours, minutes: $minutes)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Common Durations")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.secondaryText)
                
                // Minutes presets
                HStack(spacing: 4) {
                    ForEach(minutePresets) { preset in
                        PresetButton(hours: $hours, minutes: $minutes, preset: preset)
                    }
                }
                
                // Hours presets
                HStack(spacing: 4) {
                    ForEach(hourPresets) { preset in
                        PresetButton(hours: $hours, minutes: $minutes, preset: preset)
                    }
                }
            }
        }
    }
}

struct PresetButton: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    let preset: DurationPreset
    
    var body: some View {
        Button {
            hours = preset.hours
            minutes = preset.minutes
        } label: {
            if preset.hours > 0 {
                Text("\(preset.hours)h\(preset.minutes > 0 ? " \(preset.minutes)m" : "")")
            } else {
                Text("\(preset.minutes)m")
            }
        }
        .buttonStyle(.bordered)
        .tint(hours == preset.hours && minutes == preset.minutes ? AppColors.primary : AppColors.buttonDisabled)
        .font(.system(size: 10, weight: .medium))
        .padding(.vertical, 1)
    }
}

// Add TimingModeSelector view
struct TimingModeSelector: View {
    @Binding var selectedMode: TimingMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mode:")
                .foregroundColor(AppColors.secondaryText)
                .font(.system(size: 13))
            
            HStack(spacing: 8) {
                ForEach([TimingMode.timer, TimingMode.stopwatch], id: \.self) { mode in
                    Button(action: {
                        selectedMode = mode
                    }) {
                        HStack {
                            Image(systemName: mode == .timer ? "timer" : "stopwatch")
                            Text(mode == .timer ? "Timer" : "Stopwatch")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedMode == mode ? AppColors.primary.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var title = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 25
    @State private var selectedMode: TimingMode = .timer
    let commonDurations = [
        // Short durations
        DurationPreset(hours: 0, minutes: 5),    
        DurationPreset(hours: 0, minutes: 15),   
        DurationPreset(hours: 0, minutes: 25),   
        DurationPreset(hours: 0, minutes: 30),   
        DurationPreset(hours: 0, minutes: 45),   
        // Hour-based duration
        DurationPreset(hours: 1, minutes: 0),    
        DurationPreset(hours: 1, minutes: 30),   
        DurationPreset(hours: 2, minutes: 0),    
        DurationPreset(hours: 3, minutes: 0),    
        DurationPreset(hours: 4, minutes: 0)     
    ]
    let onAdd: (String, TimeInterval, TimingMode) -> Void
    
    private var totalMinutes: Double {
        Double(hours * 60 + minutes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TimePreviewView(duration: totalMinutes)
                .frame(maxWidth: .infinity)
                .opacity(selectedMode == .timer ? 1 : 0.5)
            
            TaskInputSection(title: $title)
            
            TimingModeSelector(selectedMode: $selectedMode)
            
            if selectedMode == .timer {
                DurationSection(
                    hours: $hours,
                    minutes: $minutes,
                    commonDurations: commonDurations
                )
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Save") {
                    onAdd(title, totalMinutes * 60, selectedMode)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .disabled(title.isEmpty || (selectedMode == .timer && totalMinutes == 0))
            }
            .padding(.top, 8)
        }
        .padding(16)
        .frame(width: 300)
        .background(AppColors.background)
        .frame(width: 300)
        .onChange(of: hours) { oldValue, newValue in
            if newValue < 0 { hours = 0 }
            if newValue > 24 { hours = 24 }
        }
        .onChange(of: minutes) { oldValue, newValue in
            if newValue < 0 { minutes = 0 }
            if newValue > 59 { minutes = 59 }
            if hours == 24 { minutes = 0 }
        }
    }
} 
