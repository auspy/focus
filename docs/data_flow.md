# Data Flow

## Window Communication Flow
1. Main Window → Timer Widget
   - Start Working button triggers first task
   - Task selection triggers widget
   - State updates sync between windows
   - Timer controls affect both views

## Task State Flow
1. Task Selection
   - User clicks Start Working to begin first task
   - Tasks follow user-defined order (drag-to-reorder)
   - TaskManager updates currentTask
   - Widget window receives task update
   - Timer initializes with task duration

2. Timer Flow
   - Widget controls timer
   - State syncs back to main window
   - Completion updates both views
   - On task completion:
     - Show celebration animation with confetti
     - Auto-progress to next task if available
     - Show final celebration if all tasks complete
     - Widget remains open until manual close

## Window Management
1. Main Window
   - Standard window level
   - Normal app lifecycle

2. Timer Widget
   - Floating window level
   - Persists above other windows
   - Minimal interaction mode
   - Handles task transitions
   - Manages celebration animations
   - Manual close only

## Data Storage
- Tasks → Core Data
- Task order → Core Data (ordinal position)
- Window positions → UserDefaults
- Settings → UserDefaults
- Analytics → Core Data (batch processing)

## State Updates (Real-time)
- TaskManager → Both Windows
- Timer → Both Windows
- Task Status → Analytics → Storage

## Performance Notes
- Efficient window communication
- Minimal state updates
- Optimized window rendering
- Cache active task data