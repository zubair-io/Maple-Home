import SwiftUI

@main
struct Maple_HomeApp: App {
    @State private var vm = DashboardViewModel(
        client: HAWebSocketClient()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(vm)
        }
    }
}
