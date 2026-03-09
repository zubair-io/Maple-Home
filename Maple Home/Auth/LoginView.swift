import SwiftUI

struct LoginView: View {
    @Environment(DashboardViewModel.self) private var vm
    @State private var serverURLText = ""
    @State private var tokenText = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var showTokenInput = false

    var body: some View {
        VStack(spacing: Spacing.sp7) {
            Spacer()

            // Wordmark
            VStack(spacing: Spacing.sp2) {
                Text("Casita")
                    .font(.merriweather(size: 48, weight: .black))
                    .foregroundStyle(Color.textPrimary)
                Text("Your home, clearly.")
                    .font(.merriweather(size: 20, weight: .light, italic: true))
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            // URL input
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                Text("HOME ASSISTANT URL")
                    .font(.lato(size: 11, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(1.0)

                TextField("http://homeassistant.local:8123", text: $serverURLText)
                    .textFieldStyle(.plain)
                    .font(.lato(size: 15))
                    .padding(Spacing.sp3)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.borderStrong, lineWidth: 1.5)
                    )
                    #if os(iOS)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    #endif

                if showTokenInput {
                    Text("LONG-LIVED ACCESS TOKEN")
                        .font(.lato(size: 11, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(1.0)
                        .padding(.top, Spacing.sp2)

                    SecureField("Paste your token here", text: $tokenText)
                        .textFieldStyle(.plain)
                        .font(.lato(size: 15))
                        .padding(Spacing.sp3)
                        .background(Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .stroke(Color.borderStrong, lineWidth: 1.5)
                        )
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.lato(size: 12, weight: .bold))
                        .foregroundStyle(Color.error)
                }
            }

            // Connect button
            Button {
                Task { await connect() }
            } label: {
                HStack {
                    if isConnecting {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    }
                    Text(isConnecting ? "Connecting\u{2026}" : "Connect to Home Assistant")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(MapleButtonStyle(variant: .primary))
            .disabled(serverURLText.isEmpty || isConnecting)

            // Token toggle
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    showTokenInput.toggle()
                }
            } label: {
                Text(showTokenInput ? "Use OAuth instead" : "Use a long-lived token instead")
                    .font(.lato(size: 13))
                    .foregroundStyle(Color.accent)
            }
            .buttonStyle(.plain)

            Text("Works with any Home Assistant instance \u{2014} local or remote.")
                .font(.lato(size: 13, weight: .light))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: Spacing.sp7)
        }
        .padding(Spacing.sp7)
        .background(Color.base.ignoresSafeArea())
    }

    private func connect() async {
        let trimmed = serverURLText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else {
            errorMessage = "That doesn't look like a valid URL."
            return
        }

        isConnecting = true
        errorMessage = nil

        do {
            if showTokenInput && !tokenText.isEmpty {
                // Direct token auth
                try AuthManager.shared.saveToken(tokenText.trimmingCharacters(in: .whitespacesAndNewlines), serverURL: url)
                await vm.connect()
            } else {
                // OAuth flow
                try await AuthManager.shared.authenticate(serverURL: url)
                await vm.connect()
            }
        } catch AuthError.unreachable {
            errorMessage = "Couldn't reach that address. Check the URL and try again."
        } catch AuthError.notHAInstance {
            errorMessage = "That URL doesn't look like a Home Assistant instance."
        } catch {
            errorMessage = "Authentication failed. Please try again."
        }

        isConnecting = false
    }
}
