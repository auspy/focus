# Data Flow

## Window Communication Flow
1. Main Window → Timer Widget
   - Task selection triggers widget
   - State updates sync between windows
   - Timer controls affect both views

## Task State Flow
1. Task Selection
   - User selects task in main window
   - TaskManager updates currentTask
   - Widget window receives task update
   - Timer initializes with task duration

2. Timer Flow
   - Widget controls timer
   - State syncs back to main window
   - Completion updates both views

## Window Management
1. Main Window
   - Standard window level
   - Normal app lifecycle

2. Timer Widget
   - Floating window level
   - Persists above other windows
   - Minimal interaction mode

## Data Storage
- Tasks → Core Data
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