import Foundation

class SessionSyncManager {
    static let shared = SessionSyncManager()

    private let syncedProfilesPath: String
    private let chromeProfilesPath: String

    private init() {
        syncedProfilesPath = NSHomeDirectory() + "/chrome-remote-profiles"
        chromeProfilesPath = NSHomeDirectory() + "/Library/Application Support/Google/Chrome"

        // Create synced profiles directory
        try? FileManager.default.createDirectory(
            atPath: syncedProfilesPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    // MARK: - Profile Syncing

    func syncProfileFromChrome(profileName: String) -> Bool {
        let sourcePath = chromeProfilesPath + "/" + profileName
        let destinationPath = syncedProfilesPath + "/" + profileName

        // Check if source exists
        guard FileManager.default.fileExists(atPath: sourcePath) else {
            print("Source profile not found: \(sourcePath)")
            return false
        }

        // Remove old synced profile if exists
        if FileManager.default.fileExists(atPath: destinationPath) {
            try? FileManager.default.removeItem(atPath: destinationPath)
        }

        // Create destination directory
        try? FileManager.default.createDirectory(
            atPath: destinationPath,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Critical files to sync for session preservation
        let criticalFiles = [
            "Cookies",
            "Login Data",
            "Web Data",
            "History",
            "Preferences",
            "Secure Preferences",
            "Network Action Predictor",
            "Network Persistent State",
            "TransportSecurity",
            "Extension Cookies"
        ]

        var successCount = 0

        for file in criticalFiles {
            let sourceFile = sourcePath + "/" + file
            let destFile = destinationPath + "/" + file

            if FileManager.default.fileExists(atPath: sourceFile) {
                do {
                    // Copy file
                    try FileManager.default.copyItem(atPath: sourceFile, toPath: destFile)
                    successCount += 1
                    print("✓ Synced: \(file)")
                } catch {
                    print("✗ Failed to sync \(file): \(error)")
                }
            }
        }

        // Also copy the entire Default directory structure if it exists
        let sourceDefault = sourcePath + "/Default"
        let destDefault = destinationPath + "/Default"

        if FileManager.default.fileExists(atPath: sourceDefault) {
            try? FileManager.default.removeItem(atPath: destDefault)
            try? FileManager.default.copyItem(atPath: sourceDefault, toPath: destDefault)
            print("✓ Synced Default directory")
        }

        // Copy extensions if they exist
        let sourceExtensions = sourcePath + "/Extensions"
        let destExtensions = destinationPath + "/Extensions"

        if FileManager.default.fileExists(atPath: sourceExtensions) {
            try? FileManager.default.removeItem(atPath: destExtensions)
            try? FileManager.default.copyItem(atPath: sourceExtensions, toPath: destExtensions)
            print("✓ Synced Extensions")
        }

        print("Profile sync completed: \(successCount)/\(criticalFiles.count) files synced")
        return successCount > 0
    }

    func syncAllProfiles() -> Int {
        var syncedCount = 0

        // Sync Default profile
        if FileManager.default.fileExists(atPath: chromeProfilesPath + "/Default") {
            if syncProfileFromChrome(profileName: "Default") {
                syncedCount += 1
            }
        }

        // Sync numbered profiles
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: chromeProfilesPath)
            for item in contents {
                if item.hasPrefix("Profile ") {
                    if syncProfileFromChrome(profileName: item) {
                        syncedCount += 1
                    }
                }
            }
        } catch {
            print("Error scanning profiles: \(error)")
        }

        return syncedCount
    }

    func getSyncedProfilePath(for profileName: String) -> String {
        return syncedProfilesPath + "/" + profileName
    }

    func isSyncedProfileAvailable(for profileName: String) -> Bool {
        let path = getSyncedProfilePath(for: profileName)

        // Check if synced profile exists and has critical files
        let cookiesPath = path + "/Default/Cookies"
        let prefsPath = path + "/Default/Preferences"

        return FileManager.default.fileExists(atPath: cookiesPath) ||
               FileManager.default.fileExists(atPath: prefsPath)
    }

    func getLastSyncDate(for profileName: String) -> Date? {
        let path = getSyncedProfilePath(for: profileName)

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            return attributes[.modificationDate] as? Date
        } catch {
            return nil
        }
    }

    // MARK: - Profile Info

    func getProfileAccountInfo(for profileName: String) -> String? {
        let sourcePath = chromeProfilesPath + "/" + profileName
        let prefsPath = sourcePath + "/Preferences"

        guard FileManager.default.fileExists(atPath: prefsPath),
              let data = try? Data(contentsOf: URL(fileURLWithPath: prefsPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accountInfo = json["account_info"] as? [[String: Any]],
              let firstAccount = accountInfo.first,
              let email = firstAccount["email"] as? String else {
            return nil
        }

        return email
    }

    func ensureProfileSynced(for profileName: String) -> Bool {
        // Check if already synced
        if isSyncedProfileAvailable(for: profileName) {
            // Check if sync is recent (less than 1 hour old)
            if let lastSync = getLastSyncDate(for: profileName),
               Date().timeIntervalSince(lastSync) < 3600 {
                return true
            }
        }

        // Sync now
        return syncProfileFromChrome(profileName: profileName)
    }
}
