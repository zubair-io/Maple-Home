import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DashboardViewModel.self) private var vm

    @State private var showSignOutConfirmation = false
    @State private var showSwitchConfirmation = false
    @State private var pendingSwitchURL: URL?

    var body: some View {
        NavigationStack {
            List {
                // Connection info
                Section {
                    HStack {
                        Text("Server")
                            .font(.lato(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(AuthManager.shared.serverURL?.host ?? "—")
                            .font(.lato(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }

                    HStack {
                        Text("Status")
                            .font(.lato(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        HStack(spacing: Spacing.sp1) {
                            Circle()
                                .fill(vm.connectionState.isConnected ? Color.entitySwitch : Color.error)
                                .frame(width: 8, height: 8)
                            Text(statusText)
                                .font(.lato(size: 14))
                                .foregroundStyle(Color.textMuted)
                        }
                    }

                    if case .connected(let version) = vm.connectionState {
                        HStack {
                            Text("HA Version")
                                .font(.lato(size: 14, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(version)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(Color.textMuted)
                        }
                    }
                } header: {
                    Text("CONNECTION")
                        .font(.lato(size: 11, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(1.0)
                }

                // Remote access
                if vm.connectionState.isConnected {
                    Section {
                        if let internalURL = vm.remoteAccess.internalURL {
                            HStack {
                                Text("Internal URL")
                                    .font(.lato(size: 14, weight: .bold))
                                    .foregroundStyle(Color.textSecondary)
                                Spacer()
                                Text(internalURL.host ?? internalURL.absoluteString)
                                    .font(.lato(size: 13))
                                    .foregroundStyle(Color.textMuted)
                                    .lineLimit(1)
                            }
                        }

                        if let externalURL = vm.remoteAccess.externalURL {
                            HStack {
                                Text("External URL")
                                    .font(.lato(size: 14, weight: .bold))
                                    .foregroundStyle(Color.textSecondary)
                                Spacer()
                                HStack(spacing: Spacing.sp1) {
                                    Circle()
                                        .fill(vm.remoteAccess.externalReachable ? Color.entitySwitch : Color.error)
                                        .frame(width: 8, height: 8)
                                    Text(externalURL.host ?? externalURL.absoluteString)
                                        .font(.lato(size: 13))
                                        .foregroundStyle(Color.textMuted)
                                        .lineLimit(1)
                                }
                            }
                        }

                        if let cloudURL = vm.remoteAccess.cloudURL {
                            HStack {
                                Text("Nabu Casa")
                                    .font(.lato(size: 14, weight: .bold))
                                    .foregroundStyle(Color.textSecondary)
                                Spacer()
                                HStack(spacing: Spacing.sp1) {
                                    Circle()
                                        .fill(vm.remoteAccess.cloudReachable ? Color.entitySwitch : Color.error)
                                        .frame(width: 8, height: 8)
                                    Text(cloudURL.host ?? "—")
                                        .font(.lato(size: 13))
                                        .foregroundStyle(Color.textMuted)
                                        .lineLimit(1)
                                }
                            }
                        }

                        if let bestURL = vm.remoteAccess.bestRemoteURL,
                           bestURL != AuthManager.shared.serverURL {
                            Button {
                                pendingSwitchURL = bestURL
                                showSwitchConfirmation = true
                            } label: {
                                HStack {
                                    Text("Switch to \(bestURL.host ?? "remote")")
                                        .font(.lato(size: 14, weight: .bold))
                                    Spacer()
                                    Image(systemName: "arrow.right.circle")
                                }
                            }
                        }

                        if vm.remoteAccess.externalURL == nil && vm.remoteAccess.cloudURL == nil {
                            Text("No remote access configured")
                                .font(.lato(size: 13))
                                .foregroundStyle(Color.textMuted)
                        }
                    } header: {
                        Text("REMOTE ACCESS")
                            .font(.lato(size: 11, weight: .bold))
                            .foregroundStyle(Color.textMuted)
                            .tracking(1.0)
                    }
                }

                // Stats
                Section {
                    HStack {
                        Text("Exposed Entities")
                            .font(.lato(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("\(vm.exposedEntityIds.count)")
                            .font(.lato(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }

                    HStack {
                        Text("Areas")
                            .font(.lato(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("\(vm.areas.count)")
                            .font(.lato(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }

                    HStack {
                        Text("Active Now")
                            .font(.lato(size: 14, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("\(vm.activeCount)")
                            .font(.lato(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }
                } header: {
                    Text("DASHBOARD")
                        .font(.lato(size: 11, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(1.0)
                }

                // Sign out
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .font(.lato(size: 14, weight: .bold))
                            Spacer()
                        }
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .scrollContentBackground(.hidden)
            .background(Color.base)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.lato(size: 14, weight: .bold))
                        .foregroundStyle(Color.accent)
                }
            }
            .confirmationDialog("Switch server URL?", isPresented: $showSwitchConfirmation, titleVisibility: .visible) {
                Button("Switch") {
                    if let url = pendingSwitchURL {
                        Task { await vm.switchToURL(url) }
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) { pendingSwitchURL = nil }
            } message: {
                Text("This will reconnect to \(pendingSwitchURL?.host ?? "the remote URL"). Your authentication will be preserved.")
            }
            .confirmationDialog("Sign out of Maple Home?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    vm.disconnect()
                    AuthManager.shared.signOut()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need to reconnect to your Home Assistant instance.")
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #else
        .frame(minWidth: 400, minHeight: 350)
        #endif
    }

    private var statusText: String {
        switch vm.connectionState {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting…"
        case .authenticating: return "Authenticating…"
        case .connected: return "Connected"
        case .error: return "Error"
        case .reconnecting(let attempt): return "Reconnecting (\(attempt))…"
        }
    }
}
