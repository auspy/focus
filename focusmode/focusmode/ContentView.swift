//
//  ContentView.swift
//  focusmode
//
//  Created by Kshetez Vinayak on 13/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var windowManager = WindowManager.shared
    @State private var selectedTask: Task?
    
    var body: some View {
        VStack(spacing: 0) {
            // Main task list
            TaskListView()
                .frame(minWidth: 300, minHeight: 400)
            
            // Timer style selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Timer Style")
                    .font(.headline)
                    .padding(.horizontal)
                
                ProgressStylePicker(selectedStyle: $windowManager.selectedProgressStyle)
            }
            .padding(.vertical)
            .background(Color(NSColor.separatorColor).opacity(0.1))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
