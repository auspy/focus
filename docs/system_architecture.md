# System Architecture

## Core Components

1. **Task Management Core**
   - Task data model
   - Task ordering system
   - Timer management system
   - Task state manager
   - Persistence layer
   - Auto-task progression system

2. **UI Layer**
   - Main Window Interface
     - Start Working button
     - Task list view
     - Drag-and-drop reordering
     - Dynamic task position updates
     - Task creation/editing
     - Settings panel
   - Always-on-top Timer Widget
     - Floating timer display
     - Basic controls (pause/resume)
     - Task status
     - Minimal footprint
     - Celebration animations
     - Task completion feedback
     - Auto-progression controls

3. **Window Management**
   - Main window controller
   - Floating window controller
   - Window state coordinator
   - Window persistence
   - Task transition coordinator
   - Celebration animation manager

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
- Confetti library for confetti