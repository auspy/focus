# Data Models

## Task
- id: UUID
- title: String
- description: String?
- duration: TimeInterval
- status: TaskStatus (enum)
- category: Category?
- createdAt: Date
- completedAt: Date?
- colorCode: String

## Category
- id: UUID
- name: String
- color: String
- tasks: [Task]

## UserSettings
- dndProfile: DNDProfile
- theme: Theme
- autoExtendEnabled: Bool
- analyticsEnabled: Bool
- defaultTaskDuration: TimeInterval

## Analytics
- taskId: UUID
- originalDuration: TimeInterval
- actualDuration: TimeInterval
- extensions: Int
- completionStatus: CompletionStatus 