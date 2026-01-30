import SwiftUI

struct SettingsView: View {
    @StateObject private var manager = ProjectManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var vpsHost: String = ""
    @State private var vpsPort: String = ""
    @State private var vpsUser: String = ""
    @State private var sshKeyPath: String = ""
    @State private var showingClaudePrompt = false
    @State private var showingTestResult = false
    @State private var testResult = ""
    @State private var showingSSHKey = false
    @State private var publicKey = ""
    @State private var showingSSHInstructions = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(Color(white: 0.08))

                ScrollView {
                    VStack(spacing: 25) {
                        // Startup Settings Section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "power")
                                    .foregroundColor(.green)
                                Text("Startup Settings")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                // Launch at Login Toggle
                                Toggle(isOn: Binding(
                                    get: { manager.config.launchAtLogin },
                                    set: { newValue in
                                        manager.config.launchAtLogin = newValue
                                        manager.saveConfig()
                                        // Apply immediately
                                        if let appDelegate = NSApp.delegate as? AppDelegate {
                                            appDelegate.setupLaunchAtLogin()
                                        }
                                    }
                                )) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Launch at Login")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                        Text("Start Chrome Remote Pro automatically when you log in")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .green))

                                Divider()
                                    .background(Color.white.opacity(0.1))

                                // Auto-start Projects Toggle
                                Toggle(isOn: Binding(
                                    get: { manager.config.autoStartProjects },
                                    set: { newValue in
                                        manager.config.autoStartProjects = newValue
                                        manager.saveConfig()
                                    }
                                )) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Auto-start All Projects")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                        Text("Launch all Chrome instances and SSH tunnels at startup")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .green))

                                // Info note
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.blue.opacity(0.7))
                                    Text("With these options enabled, all your projects will be ready immediately after boot")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.5))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // VPS Configuration Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("VPS Configuration")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("VPS Host")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                TextField("e.g., 192.168.1.100", text: $vpsHost)
                                    .textFieldStyle(SettingsTextFieldStyle())
                            }

                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("SSH Port")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    TextField("22", text: $vpsPort)
                                        .textFieldStyle(SettingsTextFieldStyle())
                                }

                                VStack(alignment: .leading, spacing: 10) {
                                    Text("SSH User")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    TextField("username", text: $vpsUser)
                                        .textFieldStyle(SettingsTextFieldStyle())
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("SSH Key Path")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                TextField("~/.ssh/id_rsa", text: $sshKeyPath)
                                    .textFieldStyle(SettingsTextFieldStyle())
                            }

                            // Action Buttons
                            HStack(spacing: 10) {
                                Button(action: testVPSConnection) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text("Test Connection")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.green.opacity(0.3))
                                    )
                                }
                                .buttonStyle(.plain)

                                Button(action: saveVPSConfig) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text("Save")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.blue.opacity(0.3))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // SSH Key Management Section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(.orange)
                                Text("SSH Key Management")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Generate an SSH key pair to connect securely to your VPS without passwords.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                                .fixedSize(horizontal: false, vertical: true)

                            // Generate Key Button
                            Button(action: generateSSHKey) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("Generate New SSH Key")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)

                            // Show Instructions Button
                            Button(action: { showingSSHInstructions = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("How to add SSH key to VPS")
                                        .font(.system(size: 12, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // Claude Code Prompt Section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "terminal.fill")
                                    .foregroundColor(.purple)
                                Text("Claude Code Setup")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Copy this prompt and send it to Claude Code on your VPS to automatically setup everything.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                                .fixedSize(horizontal: false, vertical: true)

                            Button(action: { showingClaudePrompt = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("Generate & Copy Prompt")
                                        .font(.system(size: 13, weight: .semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.purple.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // System Info Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("System Info")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(spacing: 8) {
                                InfoRow(label: "Local IP", value: manager.localIPAddress)
                                InfoRow(label: "Projects", value: "\(manager.projects.count)")
                                InfoRow(label: "Version", value: "2.0.0")
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            loadCurrentConfig()
        }
        .sheet(isPresented: $showingClaudePrompt) {
            ClaudePromptView()
        }
        .alert("Connection Test", isPresented: $showingTestResult) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(testResult)
        }
        .sheet(isPresented: $showingSSHKey) {
            SSHKeyView(publicKey: $publicKey)
        }
        .sheet(isPresented: $showingSSHInstructions) {
            SSHInstructionsView()
        }
    }

    private func loadCurrentConfig() {
        vpsHost = manager.config.sshHost == "localhost" ? "" : manager.config.sshHost
        vpsPort = "\(manager.config.sshPort)"
        vpsUser = manager.config.sshUser
        sshKeyPath = manager.config.sshKeyPath
    }

    private func saveVPSConfig() {
        if vpsHost.isEmpty {
            manager.config.sshHost = "localhost"
            manager.config.sshPort = 22
            manager.config.sshUser = NSUserName()
        } else {
            manager.config.sshHost = vpsHost
            manager.config.sshPort = Int(vpsPort) ?? 22
            manager.config.sshUser = vpsUser
        }

        manager.config.sshKeyPath = sshKeyPath
        manager.saveConfig()

        // Show confirmation
        testResult = "Configuration saved successfully!"
        showingTestResult = true
    }

    private func testVPSConnection() {
        if vpsHost.isEmpty {
            testResult = "Please enter VPS host first"
            showingTestResult = true
            return
        }

        let task = Process()
        task.launchPath = "/usr/bin/ssh"
        task.arguments = [
            "-i", sshKeyPath.replacingOccurrences(of: "~", with: NSHomeDirectory()),
            "-p", vpsPort,
            "-o", "ConnectTimeout=5",
            "-o", "StrictHostKeyChecking=no",
            "\(vpsUser)@\(vpsHost)",
            "echo 'Connection successful'"
        ]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if task.terminationStatus == 0 {
                testResult = "✅ Connection successful!\n\nVPS is reachable."
            } else {
                testResult = "❌ Connection failed\n\n\(output)"
            }
        } catch {
            testResult = "❌ Error: \(error.localizedDescription)"
        }

        showingTestResult = true
    }

    private func generateSSHKey() {
        let keyPath = sshKeyPath.replacingOccurrences(of: "~", with: NSHomeDirectory())
        let keyName = "chrome_remote_pro_rsa"
        let fullKeyPath = "\(NSHomeDirectory())/.ssh/\(keyName)"

        // Create .ssh directory if it doesn't exist
        let sshDir = "\(NSHomeDirectory())/.ssh"
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: sshDir) {
            do {
                try fileManager.createDirectory(atPath: sshDir, withIntermediateDirectories: true)
                try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: sshDir)
            } catch {
                testResult = "❌ Error creating .ssh directory: \(error.localizedDescription)"
                showingTestResult = true
                return
            }
        }

        // Generate SSH key
        let task = Process()
        task.launchPath = "/usr/bin/ssh-keygen"
        task.arguments = [
            "-t", "rsa",
            "-b", "4096",
            "-f", fullKeyPath,
            "-N", "",  // No passphrase
            "-C", "chrome-remote-pro@\(NSUserName())"
        ]

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                // Read public key
                let pubKeyPath = "\(fullKeyPath).pub"
                if let pubKeyData = try? Data(contentsOf: URL(fileURLWithPath: pubKeyPath)),
                   let pubKeyContent = String(data: pubKeyData, encoding: .utf8) {
                    publicKey = pubKeyContent.trimmingCharacters(in: .whitespacesAndNewlines)

                    // Update the SSH key path in the UI
                    sshKeyPath = "~/.ssh/\(keyName)"

                    // Show the public key
                    showingSSHKey = true
                }
            } else {
                testResult = "❌ Error generating SSH key"
                showingTestResult = true
            }
        } catch {
            testResult = "❌ Error: \(error.localizedDescription)"
            showingTestResult = true
        }
    }
}

// MARK: - SSH Key View

struct SSHKeyView: View {
    @Binding var publicKey: String
    @Environment(\.dismiss) var dismiss
    @State private var copied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.orange)
                    Text("Your SSH Public Key")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(Color(white: 0.08))

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Success Message
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("SSH Key Generated Successfully!")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Copy this public key and add it to your VPS's ~/.ssh/authorized_keys file.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )

                        // Public Key
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Public Key")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()

                                Button(action: copyPublicKey) {
                                    HStack(spacing: 6) {
                                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text(copied ? "Copied!" : "Copy")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(copied ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            ScrollView {
                                Text(publicKey)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.9))
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 150)
                            .padding(12)
                            .background(Color(white: 0.05))
                            .cornerRadius(8)
                        }

                        // Instructions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Next Steps:")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                InstructionStep(number: 1, text: "Copy the public key above")
                                InstructionStep(number: 2, text: "SSH to your VPS: ssh \(NSUserName())@your-vps-ip")
                                InstructionStep(number: 3, text: "Run: echo \"[paste key]\" >> ~/.ssh/authorized_keys")
                                InstructionStep(number: 4, text: "Run: chmod 600 ~/.ssh/authorized_keys")
                                InstructionStep(number: 5, text: "Test connection from Settings")
                            }
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 600, height: 500)
    }

    private func copyPublicKey() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(publicKey, forType: .string)
        copied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20, alignment: .leading)
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - SSH Instructions View

struct SSHInstructionsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("SSH Setup Guide")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(Color(white: 0.08))

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Option 1: Generate Key in App
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("1")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                Text("Generate Key in Chrome Remote Pro")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("The easiest way - let Chrome Remote Pro create the key for you!")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))

                            VStack(alignment: .leading, spacing: 6) {
                                BulletPoint(text: "Click 'Generate New SSH Key' in Settings")
                                BulletPoint(text: "Copy the public key shown")
                                BulletPoint(text: "SSH to your VPS and add the key")
                                BulletPoint(text: "Done! Test the connection")
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // Option 2: Use Existing Key
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("2")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                Text("Use Existing SSH Key")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("If you already have an SSH key pair:")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))

                            VStack(alignment: .leading, spacing: 6) {
                                BulletPoint(text: "Find your public key: ~/.ssh/id_rsa.pub")
                                BulletPoint(text: "Copy the content: cat ~/.ssh/id_rsa.pub")
                                BulletPoint(text: "SSH to VPS: ssh user@vps-ip")
                                BulletPoint(text: "Add key: echo \"[key]\" >> ~/.ssh/authorized_keys")
                                BulletPoint(text: "Set permissions: chmod 600 ~/.ssh/authorized_keys")
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // Troubleshooting
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .foregroundColor(.orange)
                                Text("Troubleshooting")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                TroubleshootItem(
                                    issue: "Permission denied",
                                    solution: "Make sure ~/.ssh/authorized_keys has 600 permissions"
                                )
                                TroubleshootItem(
                                    issue: "Connection refused",
                                    solution: "Check VPS IP, port, and SSH service is running"
                                )
                                TroubleshootItem(
                                    issue: "Key not working",
                                    solution: "Verify the correct private key path in Settings"
                                )
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(white: 0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 600, height: 650)
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct TroubleshootItem: View {
    let issue: String
    let solution: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("• \(issue)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.orange.opacity(0.9))
            Text("  → \(solution)")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}


struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct SettingsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 12, design: .monospaced))
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

// MARK: - Claude Prompt View

struct ClaudePromptView: View {
    @StateObject private var manager = ProjectManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var copied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "terminal.fill")
                        .foregroundColor(.purple)
                    Text("Claude Code VPS Setup")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(Color(white: 0.08))

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Instructions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How to use:")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("1. Copy the prompt below")
                                Text("2. SSH to your VPS: ssh -p \(manager.config.sshPort) \(manager.config.sshUser)@\(manager.config.sshHost)")
                                Text("3. Launch Claude Code on your VPS")
                                Text("4. Paste the prompt and send it")
                                Text("5. Claude will setup everything automatically!")
                            }
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )

                        // Prompt
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Generated Prompt")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()

                                Button(action: copyPrompt) {
                                    HStack(spacing: 6) {
                                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text(copied ? "Copied!" : "Copy")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(copied ? Color.green.opacity(0.3) : Color.purple.opacity(0.3))
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            ScrollView {
                                Text(generatedPrompt)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.9))
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 300)
                            .padding(12)
                            .background(Color(white: 0.05))
                            .cornerRadius(8)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 700, height: 600)
    }

    private var generatedPrompt: String {
        let projectsList = manager.projects.map { project in
            "- \(project.name) (Port \(project.port)) - \(getProfileEmail(project.chromeProfile) ?? "No email")"
        }.joined(separator: "\n")

        return """
        Salut Claude! J'ai installé Chrome Remote Pro sur mon Mac et je veux configurer mon VPS pour le contrôle distant.

        # MA CONFIGURATION

        Mac Local IP: \(manager.localIPAddress)
        VPS IP: \(manager.config.sshHost)
        VPS User: \(manager.config.sshUser)
        SSH Port: \(manager.config.sshPort)

        Mes projets Chrome Remote Pro:
        \(projectsList)

        # CE QUE JE VEUX

        Configure automatiquement ce VPS pour Chrome Remote Pro:

        ## 1. ENVIRONNEMENT
        - Installe Node.js 20+ si nécessaire
        - Installe puppeteer-core
        - Installe les outils nécessaires (curl, jq, etc.)

        ## 2. STRUCTURE
        Crée cette structure:
        ```
        ~/chrome-remote-control/
        ├── config.json                  (Configuration avec mes projets)
        ├── package.json                 (Dependencies)
        ├── test-connections.js          (Teste tous les ports)
        ├── monitor.sh                   (Monitoring temps réel)
        ├── check-tunnels.sh            (Vérifie tunnels SSH)
        └── scripts/
            └── [un dossier par projet]/
                ├── example.js
                └── README.md
        ```

        ## 3. SCRIPTS

        ### test-connections.js
        Crée un script qui:
        - Teste la connexion à chaque port \(manager.projects.map { "\($0.port)" }.joined(separator: ", "))
        - Affiche le nombre de tabs pour chaque projet
        - Vérifie que les sessions Google sont actives

        ### monitor.sh
        Script bash qui affiche en temps réel:
        ```
        🔍 Chrome Remote Pro - Connection Monitor

        \(manager.projects.map { "\($0.name) (\($0.port)):       ✅ Active - X tabs" }.joined(separator: "\n"))

        Status: X/\(manager.projects.count) projects connected
        Last update: [timestamp]
        ```

        Rafraîchit toutes les 5 secondes.

        ### check-tunnels.sh
        Vérifie que les tunnels SSH sont actifs:
        ```bash
        netstat -tlnp | grep -E '(\(manager.projects.map { "\($0.port)" }.joined(separator: "|")))'
        ```

        ### Scripts par projet
        Pour chaque projet, crée un dossier avec:
        - `example.js`: Script Puppeteer exemple qui se connecte au Chrome
        - `README.md`: Doc spécifique au projet

        ## 4. CONFIGURATION

        Le fichier `config.json` doit contenir:
        ```json
        {
          "projects": [
        \(manager.projects.map { project in
            let email = getProfileEmail(project.chromeProfile) ?? "unknown@example.com"
            return """
                {
                  "name": "\(project.name)",
                  "port": \(project.port),
                  "email": "\(email)",
                  "description": "Project \(project.name)"
                }
            """
        }.joined(separator: ",\n"))
          ],
          "vps": {
            "host": "\(manager.config.sshHost)",
            "user": "\(manager.config.sshUser)",
            "sshPort": \(manager.config.sshPort)
          }
        }
        ```

        ## 5. DOCUMENTATION

        Crée un `README.md` dans `~/chrome-remote-control/` qui explique:
        - Comment utiliser chaque script
        - Exemples Puppeteer pour chaque projet
        - Troubleshooting

        ## 5. VÉRIFICATION SSH (IMPORTANT!)

        **Avant de continuer, vérifie que la clé SSH publique du Mac est bien autorisée sur ce VPS:**

        ```bash
        # Vérifie si le fichier existe
        ls -la ~/.ssh/authorized_keys

        # Affiche les clés autorisées
        cat ~/.ssh/authorized_keys
        ```

        **Si la clé du Mac n'est PAS présente:**
        1. Sur ton Mac, dans Chrome Remote Pro, va dans Settings → SSH Key Management
        2. Clique "Generate New SSH Key" (si tu n'en as pas déjà une)
        3. Copie la clé publique affichée
        4. Sur ce VPS, ajoute-la:
        ```bash
        # Crée le dossier .ssh si nécessaire
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh

        # Ajoute la clé publique (remplace [COLLE_LA_CLÉ] par la vraie clé)
        echo "[COLLE_LA_CLÉ]" >> ~/.ssh/authorized_keys

        # Configure les permissions
        chmod 600 ~/.ssh/authorized_keys
        ```

        5. Teste la connexion depuis Chrome Remote Pro: Settings → Test Connection

        ## IMPORTANT

        - Les ports sont en localhost sur ce VPS (pas exposés publiquement)
        - Les sessions Google sont DÉJÀ actives dans les Chrome (pas de login)
        - Utilise TOUJOURS `browser.disconnect()`, JAMAIS `browser.close()`
        - Si connexion échoue, c'est que Chrome Remote Pro n'est pas lancé sur le Mac
        - SSH doit être configuré AVANT de pouvoir utiliser les tunnels

        ## EXEMPLE SCRIPT PUPPETEER

        Voici le template à utiliser:
        ```javascript
        const puppeteer = require('puppeteer-core');

        async function example(projectName, port) {
            console.log(`🚀 Connecting to ${projectName} (port ${port})...`);

            try {
                const browser = await puppeteer.connect({
                    browserURL: `http://localhost:${port}`,
                    defaultViewport: null
                });

                console.log(`✅ Connected to ${projectName}!`);

                // Get existing tabs
                const pages = await browser.pages();
                console.log(`📄 Found ${pages.length} tabs`);

                // Create new tab
                const page = await browser.newPage();

                // TON AUTOMATISATION ICI
                await page.goto('https://example.com');

                console.log('✨ Task completed!');

                // IMPORTANT: Disconnect, ne ferme PAS le browser
                await browser.disconnect();

            } catch (error) {
                console.error(`❌ Error: ${error.message}`);
            }
        }

        // Utilisation
        example('\(manager.projects.first?.name ?? "Project")', \(manager.projects.first?.port ?? 9222));
        ```

        ## ACTION

        Fais tout le setup maintenant! Crée tous les fichiers, installe les dépendances, et donne-moi un résumé de ce qui a été créé.

        Documente chaque étape et teste les connexions si possible (si Chrome Remote Pro tourne sur mon Mac).

        Prêt? Go! 🚀
        """
    }

    private func copyPrompt() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedPrompt, forType: .string)
        copied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }

    private func getProfileEmail(_ profileName: String) -> String? {
        let prefsPath = NSHomeDirectory() + "/Library/Application Support/Google/Chrome/\(profileName)/Preferences"

        guard FileManager.default.fileExists(atPath: prefsPath),
              let data = try? Data(contentsOf: URL(fileURLWithPath: prefsPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let accountInfo = json["account_info"] as? [[String: Any]],
           let firstAccount = accountInfo.first,
           let email = firstAccount["email"] as? String {
            return email
        }

        return nil
    }
}
