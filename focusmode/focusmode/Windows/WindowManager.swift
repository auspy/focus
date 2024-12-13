import SwiftUI
import AppKit

class WindowManager: NSObject, ObservableObject {
    static let shared = WindowManager()
    private var floatingWindow: NSWindow?
    private let windowPositionKey = "FloatingWindowPosition"
    private var workspaceObserver: NSObjectProtocol?
    private var currentScreen: NSScreen?
    @Published var selectedProgressStyle: ProgressStyle = .wave
    
    override init() {
        super.init()
        setupWorkspaceObserver()
    }
    
    deinit {
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }
    
    private func setupWorkspaceObserver() {
        // Observe active space changes
        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSpaceChange()
        }
    }
    
    private func handleSpaceChange() {
        guard let window = floatingWindow,
              let windowScreen = window.screen,
              let activeScreen = NSScreen.main else { return }
        
        if windowScreen == activeScreen {
            window.orderFrontRegardless()
        }
    }
    
    func showFloatingTimer(for task: Task) {
        if let existingWindow = floatingWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        // Create as a panel instead of regular window
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 40),
            styleMask: [
                .closable,
                .nonactivatingPanel,
                .hudWindow,
                .titled  // Remove if you don't want title bar
            ],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Focus Timer"
        
        // Set window level to floating panel (used by system UI)
        window.level = .floating
        
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .fullScreenAuxiliary
        ]
        
        // Panel-specific settings
        window.becomesKeyOnlyIfNeeded = true
        window.hidesOnDeactivate = false
        window.isFloatingPanel = true  // Make it float
        window.isReleasedWhenClosed = false
        
        window.backgroundColor = .clear
        window.isOpaque = false
        
        // Make window movable by dragging anywhere in the window
        window.isMovableByWindowBackground = true
        
        // Set frame autosave name
        window.setFrameAutosaveName("FloatingTimer")
        
        // Restore last position or center if none saved
        if let savedPosition = getSavedWindowPosition() {
            window.setFrameOrigin(savedPosition)
        } else {
            window.center()
        }
        
        let timerView = FloatingTimerView(task: task, progressStyle: .constant(selectedProgressStyle))
        window.contentView = NSHostingView(rootView: timerView)
        
        // Save position when window is moved
        window.delegate = self
        
        window.makeKeyAndOrderFront(nil)
        self.floatingWindow = window
        
        // Track initial screen
        currentScreen = window.screen
    }
    
    func closeFloatingWindow() {
        if let window = floatingWindow {
            saveWindowPosition(window.frame.origin)
        }
        floatingWindow?.close()
        floatingWindow = nil
    }
    
    private func saveWindowPosition(_ position: NSPoint) {
        let positionDict: [String: CGFloat] = [
            "x": position.x,
            "y": position.y
        ]
        UserDefaults.standard.set(positionDict, forKey: windowPositionKey)
    }
    
    private func getSavedWindowPosition() -> NSPoint? {
        guard let positionDict = UserDefaults.standard.dictionary(forKey: windowPositionKey) as? [String: CGFloat],
              let x = positionDict["x"],
              let y = positionDict["y"] else {
            return nil
        }
        return NSPoint(x: x, y: y)
    }
}

extension WindowManager: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        saveWindowPosition(window.frame.origin)
    }
    
    // Handle screen changes
    func windowDidChangeScreen(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        // Update current screen when window is moved to different monitor
        currentScreen = window.screen
        saveWindowPosition(window.frame.origin)
    }
    
    // Handle screen changes with animation
    func windowDidChangeScreenProfile(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        window.invalidateShadow()
    }
} 
