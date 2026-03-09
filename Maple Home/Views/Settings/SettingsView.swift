import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DashboardViewModel.self) private var vm

    @State private var showSignOutConfirmation = false

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
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.base)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.lato(size: 14, weight: .bold))
                        .foregroundStyle(Color.accent)
                }
            }
            .confirmationDialog("Sign out of Casita?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
