# System Architecture

## Core Components

1. **Task Management Core**
   - Task data model
   - Timer management system
   - Task state manager
   - Persistence layer

2. **UI Layer**
   - Main Window Interface
     - Task list view
     - Task creation/editing
     - Settings panel
   - Always-on-top Timer Widget
     - Floating timer display
     - Basic controls (pause/resume)
     - Task status
     - Minimal footprint

3. **Window Management**
   - Main window controller
   - Floating window controller
   - Window state coordinator
   - Window persistence

4. **System Integration**
   - Do Not Disturb (DND) manager
   - Notification system
   - Window level management
   - System status monitoring

## Technical Stack
- SwiftUI for UI components
- AppKit integration for window management
- Core Data for persistence
- NotificationCenter for inter-window communication 