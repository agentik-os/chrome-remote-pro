import SwiftUI

struct ContentView: View {
    @StateObject private var manager = ProjectManager.shared
    @State private var showingAddProject = false
    @State private var selectedProject: Project?

    var body: some View {
        ZStack {
            // Solid black background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HeaderView()

                Divider()
                    .background(Color.white.opacity(0.15))

                // Projects List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(manager.projects) { project in
                            ProjectCard(project: project)
                                .contextMenu {
                                    Button("Edit") {
                                        selectedProject = project
                                    }

                                    Divider()

                                    if project.isActive {
                                        Button("Stop") {
                                            manager.stopProject(project)
                                        }
                                    } else {
                                        Button("Start") {
                                            manager.startProject(project)
                                        }
                                    }

                                    Divider()

                                    Button("Delete", role: .destructive) {
                                        manager.deleteProject(project)
                                    }
                                }
                        }
                    }
                    .padding(16)
                }

                Divider()
                    .background(Color.white.opacity(0.15))

                // Control Bar
                ControlBar(showingAddProject: $showingAddProject)
            }
        }
        .frame(width: 380, height: 540)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
                .preferredColorScheme(.dark)
        }
        .sheet(item: $selectedProject) { project in
            EditProjectView(project: project)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    @StateObject private var manager = ProjectManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Top row
            HStack(spacing: 12) {
                // Icon
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "circle.grid.3x3")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Chrome Remote Pro")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Text("\(manager.projects.count) projects")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Single Refresh button with menu
                Menu {
                    Button("Refresh Status") {
                        manager.refresh()
                        manager.updateLocalIPAddress()
                    }

                    Button("Reconnect VPS") {
                        manager.reconnectVPS()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // IP Address row
            HStack(spacing: 6) {
                Image(systemName: "network")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))

                Text("Local IP: \(manager.localIPAddress)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Text("VPS: \(manager.config.sshHost)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(Color(white: 0.08))
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    let project: Project
    @StateObject private var manager = ProjectManager.shared
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 12) {
                // Status indicator - COLORED
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 3) {
                    Text(project.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    if let email = getProfileEmail(project.chromeProfile) {
                        Text(email)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Port badge (now clickable to open window)
                Button(action: {
                    if project.isActive {
                        manager.openChromeWindow(project)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 9, weight: .medium))
                        Text(":\(project.port)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(project.isActive ? Color.white.opacity(0.2) : Color.white.opacity(0.10))
                    )
                }
                .buttonStyle(.plain)
                .disabled(!project.isActive)
                .help(project.isActive ? "Open Chrome window" : "Start project first")

                // Play/Stop button
                Button(action: {
                    if project.isActive {
                        manager.stopProject(project)
                    } else {
                        manager.startProject(project)
                    }
                }) {
                    Image(systemName: project.isActive ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // Status bar
            HStack(spacing: 0) {
                StatusItem(label: "Chrome", status: project.chromeStatus)
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 12)

                StatusItem(label: "Tunnel", status: project.tunnelStatus)
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 12)

                StatusItem(label: "VPS", status: project.vpsStatus)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color(white: 0.05))
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: isHovered ? 0.14 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            if project.isActive {
                manager.openChromeWindow(project)
            }
        }
        .help(project.isActive ? "Click to open Chrome window for \(project.name)" : "Start project first to open its Chrome window")
    }

    var statusColor: Color {
        if project.chromeStatus == .active && project.tunnelStatus == .active && project.vpsStatus == .active {
            return Color(red: 0.2, green: 0.95, blue: 0.4)
        } else if project.chromeStatus == .active || project.tunnelStatus == .active {
            return Color(red: 1.0, green: 0.7, blue: 0.0)
        } else {
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        }
    }

    func getProfileEmail(_ profileName: String) -> String? {
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

struct StatusItem: View {
    let label: String
    let status: Project.ServiceStatus

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(statusColor)
                .frame(width: 5, height: 5)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    var statusColor: Color {
        switch status {
        case .active: return Color(red: 0.2, green: 0.95, blue: 0.4)
        case .inactive: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .checking: return Color(red: 1.0, green: 0.7, blue: 0.0)
        }
    }
}

// MARK: - Control Bar

struct ControlBar: View {
    @Binding var showingAddProject: Bool
    @StateObject private var manager = ProjectManager.shared
    @State private var addHovered = false
    @State private var startHovered = false
    @State private var stopHovered = false

    var body: some View {
        HStack(spacing: 10) {
            // Add
            Button(action: {
                showingAddProject = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Add")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(addHovered ? 0.20 : 0.12))
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) {
                    addHovered = hovering
                }
            }

            // Start All
            Button(action: {
                manager.startAllProjects()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Start")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(startHovered ? 0.20 : 0.12))
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) {
                    startHovered = hovering
                }
            }

            // Stop All
            Button(action: {
                manager.stopAllProjects()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Stop")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(stopHovered ? 0.20 : 0.12))
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) {
                    stopHovered = hovering
                }
            }
        }
        .padding(14)
        .background(Color(white: 0.08))
    }
}
