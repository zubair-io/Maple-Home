import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var vm
    @State private var showSettings = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Connection banner
                    if !vm.connectionState.isConnected {
                        ConnectionBannerView(state: vm.connectionState)
                            .padding(.horizontal, Spacing.sp4)
                            .padding(.top, Spacing.sp2)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Header
                    DashboardHeaderView(activeCount: vm.activeCount)

                    // Content
                    if vm.sections.isEmpty && vm.connectionState.isConnected {
                        EmptyExposedEntitiesView()
                            .padding(.top, Spacing.sp8)
                    } else {
                        LazyVStack(spacing: Spacing.sp2, pinnedViews: []) {
                            ForEach(vm.sections) { section in
                                AreaSectionView(section: section)
                            }
                        }
                        .padding(.bottom, Spacing.sp8)
                    }
                }
            }
            .refreshable {
                await vm.reload()
            }
            .background(Color.base)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .task {
            await vm.connect()
        }
        .alert(
            "Error",
            isPresented: Bindable(vm).showCommandError,
            presenting: vm.commandError
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.message)
        }
    }
}

#Preview {
    DashboardView()
}
