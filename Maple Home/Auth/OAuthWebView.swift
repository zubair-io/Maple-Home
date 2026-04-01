import SwiftUI
import WebKit

// MARK: - OAuth Web View

#if os(iOS)
struct OAuthWebView: UIViewRepresentable {
    let url: URL
    let serverURL: URL
    let onAuthCode: (String) -> Void
    let onError: (Error) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(serverURL: serverURL, onAuthCode: onAuthCode, onError: onError)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
#else
struct OAuthWebView: NSViewRepresentable {
    let url: URL
    let serverURL: URL
    let onAuthCode: (String) -> Void
    let onError: (Error) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(serverURL: serverURL, onAuthCode: onAuthCode, onError: onError)
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {}
}
#endif

// MARK: - Coordinator

extension OAuthWebView {
    final class Coordinator: NSObject, WKNavigationDelegate {
        let serverURL: URL
        let onAuthCode: (String) -> Void
        let onError: (Error) -> Void

        init(serverURL: URL, onAuthCode: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
            self.serverURL = serverURL
            self.onAuthCode = onAuthCode
            self.onError = onError
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            print("[Maple] WebView navigating to: \(url.absoluteString)")

            // Check if this is the callback redirect
            if url.path.hasSuffix(AuthManager.callbackPath),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                print("[Maple] OAuth callback received, code: \(code.prefix(8))...")
                decisionHandler(.cancel)
                onAuthCode(code)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[Maple] WebView navigation failed: \(error)")
            onError(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("[Maple] WebView provisional navigation failed: \(error)")
            onError(error)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("[Maple] WebView finished loading: \(webView.url?.absoluteString ?? "nil")")
        }
    }
}
