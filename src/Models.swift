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

    static let `default` = AppConfig(
        projects: [],
        sshHost: "72.61.197.216",
        sshPort: 42820,
        sshUser: "hacker",
        sshKeyPath: "~/.ssh/id_rsa_vps_chrome"
    )
}
