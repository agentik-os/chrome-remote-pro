import SwiftUI
import AppKit

@main
struct ChromeRemoteProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var manager: ProjectManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status item (menu bar icon)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Chrome Remote Pro")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 580)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // Initialize manager
        manager = ProjectManager.shared
        manager.onStatusChange = { [weak self] status in
            self?.updateMenuBarIcon(status: status)
        }
        manager.startMonitoring()
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func updateMenuBarIcon(status: OverallStatus) {
        guard let button = statusItem.button else { return }

        switch status {
        case .allActive:
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "All Active")
        case .partialActive:
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Partial Active")
        case .allInactive:
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Inactive")
        }
        button.image?.isTemplate = true
    }
}
