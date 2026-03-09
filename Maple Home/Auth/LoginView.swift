import SwiftUI

struct LoginView: View {
    @Environment(DashboardViewModel.self) private var vm
    @State private var serverURLText = "http://homeassistant.local:8123"
    @State private var tokenText = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var showTokenInput = false
    @State private var showOAuthSheet = false
    @State private var oauthServerURL: URL?

    var body: some View {
        VStack(spacing: Spacing.sp7) {
            Spacer()

            // Wordmark
            VStack(spacing: Spacing.sp2) {
                HStack(spacing: 0) {
                    Text("Maple")
                        .font(.merriweather(size: 48, weight: .black))
                        .foregroundStyle(Color.textPrimary)
                    Text(".")
                        .font(.merriweather(size: 48, weight: .black))
                        .foregroundStyle(Color.accent)
                }
                Text("Your home, beautifully.")
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
        .onAppear {
            isConnecting = false
            errorMessage = nil
        }
        .sheet(isPresented: $showOAuthSheet) {
            if let serverURL = oauthServerURL,
               let authURL = AuthManager.shared.oauthURL(for: serverURL) {
                OAuthLoginSheet(
                    authURL: authURL,
                    serverURL: serverURL,
                    onComplete: { code in
                        showOAuthSheet = false
                        Task { await finishOAuth(code: code, serverURL: serverURL) }
                    },
                    onCancel: {
                        showOAuthSheet = false
                        isConnecting = false
                    },
                    onError: { error in
                        showOAuthSheet = false
                        errorMessage = "Authentication failed: \(error.localizedDescription)"
                        isConnecting = false
                    }
                )
            }
        }
    }

    // MARK: - Actions

    private func connect() async {
        let trimmed = serverURLText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else {
            errorMessage = "That doesn't look like a valid URL."
            return
        }

        isConnecting = true
        errorMessage = nil

        if showTokenInput && !tokenText.isEmpty {
            // Direct token auth — validate connection before saving
            do {
                let trimmedToken = tokenText.trimmingCharacters(in: .whitespacesAndNewlines)
                try AuthManager.shared.saveToken(trimmedToken, serverURL: url)
                // Try connecting — this will throw authFailed if the token is invalid
                await vm.connect()
                if case .disconnected = vm.connectionState {
                    // Auth was invalid, signOut already called
                    errorMessage = "Invalid token. Check your long-lived access token and try again."
                } else if case .error = vm.connectionState {
                    AuthManager.shared.signOut()
                    errorMessage = "Couldn't connect. Check the URL and token."
                }
            } catch {
                AuthManager.shared.signOut()
                errorMessage = "Connection failed: \(error.localizedDescription)"
            }
            isConnecting = false
        } else {
            // Validate, then show OAuth webview
            do {
                let restClient = HARestClient(serverURL: url)
                _ = try await restClient.validateInstance()
                oauthServerURL = url
                showOAuthSheet = true
            } catch AuthError.unreachable {
                errorMessage = "Couldn't reach that address. Check the URL and try again."
                isConnecting = false
            } catch AuthError.notHAInstance {
                errorMessage = "That URL doesn't look like a Home Assistant instance."
                isConnecting = false
            } catch {
                errorMessage = "Connection failed: \(error.localizedDescription)"
                isConnecting = false
            }
        }
    }

    private func finishOAuth(code: String, serverURL: URL) async {
        do {
            try await AuthManager.shared.exchangeCode(code, serverURL: serverURL)
            await vm.connect()
        } catch {
            errorMessage = "Token exchange failed: \(error.localizedDescription)"
        }
        isConnecting = false
    }
}

// MARK: - OAuth Login Sheet

private struct OAuthLoginSheet: View {
    let authURL: URL
    let serverURL: URL
    let onComplete: (String) -> Void
    let onCancel: () -> Void
    let onError: (Error) -> Void

    var body: some View {
        NavigationStack {
            OAuthWebView(
                url: authURL,
                serverURL: serverURL,
                onAuthCode: onComplete,
                onError: onError
            )
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Sign In")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .font(.lato(size: 14, weight: .bold))
                }
            }
        }
    }
}
