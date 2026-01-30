import SwiftUI

struct FirstRunView: View {
    @StateObject private var manager = ProjectManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var vpsHost = ""
    @State private var vpsPort = "22"
    @State private var vpsUser = ""
    @State private var sshKeyPath = "~/.ssh/id_rsa"
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "network.badge.shield.half.filled")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text("Welcome to Chrome Remote Pro")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Configure your VPS connection")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 40)
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VPS Host")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))

                        TextField("e.g., 192.168.1.100 or example.com", text: $vpsHost)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SSH Port")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            TextField("22", text: $vpsPort)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("SSH User")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))

                            TextField("your-username", text: $vpsUser)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("SSH Key Path")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))

                        TextField("~/.ssh/id_rsa", text: $sshKeyPath)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    // Info box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Optional: VPS Connection")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text("Leave empty to use Chrome Remote Pro locally only. You can configure VPS later in Settings.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.top, 10)
                }
                .padding(.horizontal, 40)

                Spacer()

                // Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        // Skip VPS configuration
                        manager.config.sshHost = "localhost"
                        manager.config.sshPort = 22
                        manager.config.sshUser = NSUserName()
                        manager.config.sshKeyPath = "~/.ssh/id_rsa"
                        manager.saveConfig()
                        dismiss()
                    }) {
                        Text("Skip for Now")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        saveConfiguration()
                    }) {
                        Text("Save & Continue")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(vpsHost.isEmpty && !vpsUser.isEmpty)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .frame(width: 550, height: 500)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveConfiguration() {
        // Validate
        if !vpsHost.isEmpty && vpsUser.isEmpty {
            errorMessage = "Please enter SSH user"
            showingError = true
            return
        }

        if !vpsHost.isEmpty {
            guard let port = Int(vpsPort), port > 0 && port < 65536 else {
                errorMessage = "Invalid port number"
                showingError = true
                return
            }
        }

        // Save
        if vpsHost.isEmpty {
            // Local only
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

        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 13, design: .monospaced))
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
