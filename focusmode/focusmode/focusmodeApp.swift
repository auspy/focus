//
//  focusmodeApp.swift
//  focusmode
//
//  Created by Kshetez Vinayak on 13/12/24.
//

import SwiftUI

@main
struct focusmodeApp: App {
    // Initialize Core Data
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
