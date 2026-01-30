import Foundation
import Combine
import Darwin

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()

    @Published var projects: [Project] = []
    @Published var availableChromeProfiles: [ChromeProfile] = []
    @Published var config: AppConfig = .default
    @Published var localIPAddress: String = "Detecting..."

    private let configPath: String
    private var timer: Timer?
    var onStatusChange: ((OverallStatus) -> Void)?

    private init() {
        configPath = NSHomeDirectory() + "/.chrome_remote_pro_config.json"
        loadConfig()
        discoverChromeProfiles()
        updateLocalIPAddress()

        // Create default projects if none exist
        if projects.isEmpty {
            createDefaultProjects()
        }
    }

    // MARK: - IP Address Detection

    func updateLocalIPAddress() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let ip = self?.getLocalIPAddress() ?? "Unknown"
            DispatchQueue.main.async {
                self?.localIPAddress = ip
            }
        }
    }

    private func getLocalIPAddress() -> String {
        var address: String = "Unknown"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else { return address }
        guard let firstAddr = ifaddr else { return address }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family

            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)

                if name == "en0" || name == "en1" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr,
                               socklen_t(interface.ifa_addr.pointee.sa_len),
                               &hostname,
                               socklen_t(hostname.count),
                               nil,
                               socklen_t(0),
                               NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }

        freeifaddrs(ifaddr)
        return address
    }

    func reconnectVPS() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.showNotification(
                    title: "Reconnecting VPS",
                    body: "Updating IP and reestablishing tunnels..."
                )
            }

            // Update IP address
            self.updateLocalIPAddress()

            // Stop all projects
            for project in self.projects {
                if project.isActive {
                    self.stopProject(project)
                }
            }

            // Wait a bit
            Thread.sleep(forTimeInterval: 2.0)

            // Restart all active projects
            for project in self.projects {
                self.startProject(project)
                Thread.sleep(forTimeInterval: 2.0)
            }

            DispatchQueue.main.async {
                self.showNotification(
                    title: "VPS Reconnected",
                    body: "All tunnels reestablished with IP: \(self.localIPAddress)"
                )
            }
        }
    }

    // MARK: - Chrome Profile Discovery

    func discoverChromeProfiles() {
        let chromePath = NSHomeDirectory() + "/Library/Application Support/Google/Chrome"
        var profiles: [ChromeProfile] = []

        // Check Default profile
        let defaultPath = chromePath + "/Default"
        if FileManager.default.fileExists(atPath: defaultPath) {
            profiles.append(ChromeProfile(name: "Default", path: defaultPath))
        }

        // Check numbered profiles
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: chromePath)
            for item in contents {
                if item.hasPrefix("Profile ") {
                    let profilePath = chromePath + "/" + item
                    profiles.append(ChromeProfile(name: item, path: profilePath))
                }
            }
        } catch {
            print("Error scanning Chrome profiles: \(error)")
        }

        availableChromeProfiles = profiles.sorted { $0.name < $1.name }
    }

    // MARK: - Project Management

    func createDefaultProjects() {
        guard !availableChromeProfiles.isEmpty else { return }

        for i in 0..<min(3, availableChromeProfiles.count) {
            let project = Project(
                name: "Project \(i + 1)",
                chromeProfile: availableChromeProfiles[i].name,
                port: 9222 + i
            )
            projects.append(project)
        }

        saveConfig()
    }

    func addProject() {
        let newNumber = projects.count + 1
        let defaultProfile = availableChromeProfiles.first?.name ?? "Default"
        let defaultPort = 9222 + projects.count

        let project = Project(
            name: "Project \(newNumber)",
            chromeProfile: defaultProfile,
            port: defaultPort
        )

        projects.append(project)
        saveConfig()
    }

    func deleteProject(_ project: Project) {
        // Stop project first if running
        if project.isActive {
            stopProject(project)
        }

        projects.removeAll { $0.id == project.id }
        saveConfig()
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveConfig()
        }
    }

    // MARK: - Config Persistence

    func loadConfig() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)) else {
            config = .default
            return
        }

        if let decoded = try? JSONDecoder().decode(AppConfig.self, from: data) {
            config = decoded
            projects = decoded.projects
        }
    }

    func saveConfig() {
        config.projects = projects

        if let encoded = try? JSONEncoder().encode(config) {
            try? encoded.write(to: URL(fileURLWithPath: configPath))
        }
    }

    // MARK: - Monitoring

    func startMonitoring() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            for i in 0..<self.projects.count {
                let project = self.projects[i]

                // Check Chrome
                let chromeActive = self.checkProcess(pattern: "Chrome.*remote-debugging-port=\(project.port)")

                // Check SSH Tunnel
                let tunnelActive = self.checkProcess(pattern: "ssh.*-R.*\(project.port):localhost:\(project.port)")

                // Check VPS endpoint
                let vpsActive = self.checkEndpoint(port: project.port)

                DispatchQueue.main.async {
                    self.projects[i].chromeStatus = chromeActive ? .active : .inactive
                    self.projects[i].tunnelStatus = tunnelActive ? .active : .inactive
                    self.projects[i].vpsStatus = vpsActive ? .active : .inactive
                    self.projects[i].isActive = chromeActive || tunnelActive
                }
            }

            DispatchQueue.main.async {
                self.updateOverallStatus()
            }
        }
    }

    private func checkProcess(pattern: String) -> Bool {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "pgrep -f '\(pattern)' > /dev/null 2>&1"]

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func checkEndpoint(port: Int) -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/curl"
        task.arguments = ["-s", "--max-time", "1", "http://localhost:\(port)/json/version"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func updateOverallStatus() {
        let allActive = projects.allSatisfy {
            $0.chromeStatus == .active && $0.tunnelStatus == .active
        }

        let someActive = projects.contains {
            $0.chromeStatus == .active || $0.tunnelStatus == .active
        }

        if allActive && !projects.isEmpty {
            onStatusChange?(.allActive)
        } else if someActive {
            onStatusChange?(.partialActive)
        } else {
            onStatusChange?(.allInactive)
        }
    }

    // MARK: - Project Control

    private func killNormalChromeInstances() {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [
            "-c",
            "pkill -f 'Google Chrome.app/Contents/MacOS/Google Chrome' | grep -v 'remote-debugging-port' || true"
        ]

        do {
            try task.run()
            task.waitUntilExit()
            Thread.sleep(forTimeInterval: 1.0) // Wait for Chrome to close
        } catch {
            print("Failed to kill normal Chrome instances: \(error)")
        }
    }

    func startProject(_ project: Project) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            // Use Chrome profile DIRECTLY (no copy!)
            let chromePath = NSHomeDirectory() + "/Library/Application Support/Google/Chrome/" + project.chromeProfile

            // Check if profile exists
            if !FileManager.default.fileExists(atPath: chromePath) {
                DispatchQueue.main.async {
                    self.showNotification(
                        title: "Error",
                        body: "Profile \(project.chromeProfile) not found!"
                    )
                }
                return
            }

            // Start Chrome with the REAL Chrome profile
            let chromeTask = Process()
            chromeTask.launchPath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            chromeTask.arguments = [
                "--remote-debugging-port=\(project.port)",
                "--user-data-dir=\(chromePath)",
                "--no-first-run",
                "--no-default-browser-check",
                "--disable-features=UserAgentClientHint",
                "--disable-blink-features=AutomationControlled"
            ]

            let nullDevice = FileHandle.nullDevice
            chromeTask.standardOutput = nullDevice
            chromeTask.standardError = nullDevice

            do {
                try chromeTask.run()
            } catch {
                print("Failed to start Chrome for \(project.name): \(error)")
                return
            }

            // Wait for Chrome to start
            Thread.sleep(forTimeInterval: 3.0)

            // Open a visible Chrome window with Google homepage
            DispatchQueue.main.async {
                let openScript = """
                tell application "Google Chrome"
                    activate
                    set windowList to every window
                    if (count of windowList) = 0 then
                        make new window
                    end if
                    tell front window
                        set active tab index to 1
                        set URL of active tab to "https://www.google.com"
                    end tell
                end tell
                """

                let openTask = Process()
                openTask.launchPath = "/usr/bin/osascript"
                openTask.arguments = ["-e", openScript]
                try? openTask.run()
            }

            // Start SSH Tunnel
            self.startSSHTunnel(for: project)

            DispatchQueue.main.async {
                self.refresh()
                self.showNotification(
                    title: "Started",
                    body: "\(project.name) - All Google accounts are ready!"
                )
            }
        }
    }

    func syncAllSessions() {
        DispatchQueue.global(qos: .background).async {
            let syncManager = SessionSyncManager.shared
            let count = syncManager.syncAllProfiles()

            DispatchQueue.main.async { [weak self] in
                self?.showNotification(
                    title: "Sessions Synced",
                    body: "Synchronized \(count) Chrome profiles with all Google accounts"
                )
            }
        }
    }

    func syncProjectSessions(_ project: Project) {
        DispatchQueue.global(qos: .background).async {
            let syncManager = SessionSyncManager.shared
            let success = syncManager.syncProfileFromChrome(profileName: project.chromeProfile)

            DispatchQueue.main.async { [weak self] in
                if success {
                    self?.showNotification(
                        title: "Profile Synced",
                        body: "\(project.name) sessions synchronized"
                    )
                } else {
                    self?.showNotification(
                        title: "Sync Failed",
                        body: "Could not sync \(project.chromeProfile)"
                    )
                }
            }
        }
    }

    func stopProject(_ project: Project) {
        // Kill Chrome
        let killChrome = Process()
        killChrome.launchPath = "/usr/bin/pkill"
        killChrome.arguments = ["-f", "remote-debugging-port=\(project.port)"]
        try? killChrome.run()

        // Kill SSH
        let killSSH = Process()
        killSSH.launchPath = "/usr/bin/pkill"
        killSSH.arguments = ["-f", "ssh.*-R.*\(project.port):localhost:\(project.port)"]
        try? killSSH.run()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.refresh()
            self?.showNotification(
                title: "Stopped",
                body: "\(project.name) has been stopped"
            )
        }
    }

    func startAllProjects() {
        showNotification(title: "Starting All", body: "Closing normal Chrome and launching all projects...")

        // Kill normal Chrome once before launching all projects
        killNormalChromeInstances()

        for project in projects {
            startProject(project)
            Thread.sleep(forTimeInterval: 2.0)
        }
    }

    func stopAllProjects() {
        showNotification(title: "Stopping All", body: "Stopping all projects...")

        for project in projects {
            stopProject(project)
        }
    }

    private func startSSHTunnel(for project: Project) {
        let sshTask = Process()
        sshTask.launchPath = "/usr/bin/ssh"

        var args = ["-f", "-N"]

        let sshKeyPath = config.sshKeyPath.replacingOccurrences(of: "~", with: NSHomeDirectory())
        if FileManager.default.fileExists(atPath: sshKeyPath) {
            args.append(contentsOf: ["-i", sshKeyPath])
        }

        args.append(contentsOf: [
            "-R", "\(project.port):localhost:\(project.port)",
            "-p", "\(config.sshPort)",
            "-o", "ServerAliveInterval=60",
            "-o", "ServerAliveCountMax=3",
            "-o", "StrictHostKeyChecking=no",
            "\(config.sshUser)@\(config.sshHost)"
        ])

        sshTask.arguments = args

        let errorLog = FileHandle(forWritingAtPath: "/tmp/chrome-remote-\(project.port)-error.log")
        sshTask.standardError = errorLog

        do {
            try sshTask.run()
        } catch {
            print("Failed to start SSH tunnel for \(project.name): \(error)")
        }
    }

    func openChromeWindow(_ project: Project) {
        // Use AppleScript to activate Chrome and bring window to front
        let script = """
        tell application "Google Chrome"
            activate
            set windowList to every window
            repeat with theWindow in windowList
                set tabList to every tab of theWindow
                repeat with theTab in tabList
                    if URL of theTab contains "localhost:\(project.port)" then
                        set active tab index of theWindow to index of theTab
                        set index of theWindow to 1
                        return
                    end if
                end repeat
            end repeat
        end tell
        """

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        do {
            try task.run()
            task.waitUntilExit()

            // If no specific window found, just activate Chrome
            if task.terminationStatus != 0 {
                let activateTask = Process()
                activateTask.launchPath = "/usr/bin/osascript"
                activateTask.arguments = ["-e", "tell application \"Google Chrome\" to activate"]
                try? activateTask.run()
            }
        } catch {
            print("Failed to open Chrome window: \(error)")
        }
    }

    private func showNotification(title: String, body: String) {
        DispatchQueue.main.async {
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = body
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
}

enum OverallStatus {
    case allActive, partialActive, allInactive
}
