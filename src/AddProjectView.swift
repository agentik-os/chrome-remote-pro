import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = ProjectManager.shared

    @State private var projectName = ""
    @State private var selectedProfile = ""
    @State private var port = 9222

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add New Project")
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            // Form
            Form {
                Section {
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Section {
                    Picker("Chrome Profile", selection: $selectedProfile) {
                        ForEach(manager.availableChromeProfiles) { profile in
                            Text(profile.displayName).tag(profile.name)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Chrome Profile (with your Google accounts)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Section {
                    Stepper("Port: \(port)", value: $port, in: 9222...9300)
                } header: {
                    Text("Debugging Port")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Add Project") {
                    addProject()
                }
                .buttonStyle(.borderedProminent)
                .disabled(projectName.isEmpty || selectedProfile.isEmpty)
            }
            .padding(20)
        }
        .frame(width: 450, height: 380)
        .onAppear {
            // Auto-generate name
            projectName = "Project \(manager.projects.count + 1)"

            // Select first available profile
            if let firstProfile = manager.availableChromeProfiles.first {
                selectedProfile = firstProfile.name
            }

            // Find next available port
            let usedPorts = Set(manager.projects.map { $0.port })
            var nextPort = 9222
            while usedPorts.contains(nextPort) {
                nextPort += 1
            }
            port = nextPort
        }
    }

    private func addProject() {
        let project = Project(
            name: projectName,
            chromeProfile: selectedProfile,
            port: port
        )

        manager.projects.append(project)
        manager.saveConfig()
        dismiss()
    }
}

struct EditProjectView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = ProjectManager.shared

    let project: Project

    @State private var projectName = ""
    @State private var selectedProfile = ""
    @State private var port = 9222

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Project")
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            // Form
            Form {
                Section {
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Section {
                    Picker("Chrome Profile", selection: $selectedProfile) {
                        ForEach(manager.availableChromeProfiles) { profile in
                            Text(profile.displayName).tag(profile.name)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Chrome Profile (with your Google accounts)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Section {
                    Stepper("Port: \(port)", value: $port, in: 9222...9300)
                } header: {
                    Text("Debugging Port")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Save Changes") {
                    saveProject()
                }
                .buttonStyle(.borderedProminent)
                .disabled(projectName.isEmpty || selectedProfile.isEmpty)
            }
            .padding(20)
        }
        .frame(width: 450, height: 380)
        .onAppear {
            projectName = project.name
            selectedProfile = project.chromeProfile
            port = project.port
        }
    }

    private func saveProject() {
        var updatedProject = project
        updatedProject.name = projectName
        updatedProject.chromeProfile = selectedProfile
        updatedProject.port = port

        manager.updateProject(updatedProject)
        dismiss()
    }
}
