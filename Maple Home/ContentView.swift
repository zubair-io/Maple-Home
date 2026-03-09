import SwiftUI

struct ContentView: View {
    @Environment(DashboardViewModel.self) private var vm

    var body: some View {
        Group {
            if AuthManager.shared.isAuthenticated {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: AuthManager.shared.isAuthenticated)
    }
}
