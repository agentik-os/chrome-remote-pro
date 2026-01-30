import Foundation

// Project configuration
struct Project: Identifiable, Codable {
    var id: UUID
    var name: String
    var chromeProfile: String  // e.g., "Profile 1", "Default"
    var port: Int
    var isActive: Bool
    var chromeStatus: ServiceStatus
    var tunnelStatus: ServiceStatus
    var vpsStatus: ServiceStatus

    enum ServiceStatus: String, Codable {
        case active, inactive, checking
    }

    init(id: UUID = UUID(), name: String, chromeProfile: String, port: Int) {
        self.id = id
        self.name = name
        self.chromeProfile = chromeProfile
        self.port = port
        self.isActive = false
        self.chromeStatus = .checking
        self.tunnelStatus = .checking
        self.vpsStatus = .checking
    }
}

// Chrome profile info
struct ChromeProfile: Identifiable {
    let id = UUID()
    let name: String
    let path: String

    var displayName: String {
        if name == "Default" {
            return "Default Profile"
        }
        return name.replacingOccurrences(of: "Profile ", with: "Profile ")
    }
}

// App configuration
struct AppConfig: Codable {
    var projects: [Project]
    var sshHost: String
    var sshPort: Int
    var sshUser: String
    var sshKeyPath: String
    var launchAtLogin: Bool
    var autoStartProjects: Bool

    // Custom decoder to handle old configs without new fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        projects = try container.decode([Project].self, forKey: .projects)
        sshHost = try container.decode(String.self, forKey: .sshHost)
        sshPort = try container.decode(Int.self, forKey: .sshPort)
        sshUser = try container.decode(String.self, forKey: .sshUser)
        sshKeyPath = try container.decode(String.self, forKey: .sshKeyPath)
        // New fields with default values if missing
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? true
        autoStartProjects = try container.decodeIfPresent(Bool.self, forKey: .autoStartProjects) ?? true
    }

    // Regular initializer
    init(projects: [Project] = [], sshHost: String = "localhost", sshPort: Int = 22,
         sshUser: String = NSUserName(), sshKeyPath: String = "~/.ssh/id_rsa",
         launchAtLogin: Bool = true, autoStartProjects: Bool = true) {
        self.projects = projects
        self.sshHost = sshHost
        self.sshPort = sshPort
        self.sshUser = sshUser
        self.sshKeyPath = sshKeyPath
        self.launchAtLogin = launchAtLogin
        self.autoStartProjects = autoStartProjects
    }

    static let `default` = AppConfig()
}
