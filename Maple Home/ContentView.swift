import SwiftUI

struct ContentView: View {
    @Environment(DashboardViewModel.self) private var vm

    var body: some View {
        Group {
            if AuthManager.shared.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: AuthManager.shared.isAuthenticated)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(DashboardViewModel.self) private var vm

    var body: some View {
        TabView {
            RoomsView()
                .tabItem {
                    Label("Rooms", systemImage: "hexagon")
                }

            DashboardView()
                .tabItem {
                    Label("Devices", systemImage: "square.grid.2x2")
                }
        }
        .tint(Color.mapleAccent)
    }
}
