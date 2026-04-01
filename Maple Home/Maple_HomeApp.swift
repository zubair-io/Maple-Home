import SwiftUI

@main
struct Maple_HomeApp: App {
    @State private var vm = DashboardViewModel(
        client: HAWebSocketClient()
    )
    @State private var roomsVM: RoomsViewModel?
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            let resolvedRoomsVM = roomsVM ?? {
                let created = RoomsViewModel(dashboardVM: vm)
                Task { @MainActor in roomsVM = created }
                return created
            }()

            ContentView()
                .environment(vm)
                .environment(resolvedRoomsVM)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        vm.saveCacheNow()
                    }
                }
        }
    }
}
