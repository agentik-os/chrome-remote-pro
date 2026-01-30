import SwiftUI
import AppKit
import ServiceManagement

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

        // Setup launch at login
        setupLaunchAtLogin()

        // Auto-start all projects if enabled
        if manager.config.autoStartProjects {
            // Wait 5 seconds to let the app fully load
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.manager.startAllProjects()
            }
        }
    }

    func setupLaunchAtLogin() {
        let launchAtLogin = manager.config.launchAtLogin

        if #available(macOS 13.0, *) {
            // Modern API for macOS 13+
            if launchAtLogin {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        } else {
            // Legacy method for older macOS
            setLaunchAtLoginLegacy(enabled: launchAtLogin)
        }
    }

    func setLaunchAtLoginLegacy(enabled: Bool) {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.agentik.ChromeRemotePro"

        if enabled {
            // Add to login items via AppleScript
            let script = """
            tell application "System Events"
                make login item at end with properties {path:"/Users/\(NSUserName())/Applications/Chrome Remote Pro.app", hidden:false}
            end tell
            """

            if let appleScript = NSAppleScript(source: script) {
                var error: NSDictionary?
                appleScript.executeAndReturnError(&error)
                if let error = error {
                    print("Failed to add login item: \(error)")
                }
            }
        }
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
