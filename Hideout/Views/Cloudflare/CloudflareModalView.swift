import SwiftUI
import WebKit

public struct CloudflareModalView: View {
    @Environment(\.presentationMode) var presentationMode
    public let onBypassSuccess: () -> Void
    
    public init(onBypassSuccess: @escaping () -> Void) {
        self.onBypassSuccess = onBypassSuccess
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundColor(.neonOrange)
                        .font(.system(size: 16))
                    Text("Cloudflare 봇 방어막을 통과하세요. 캡차가 완료되면 자동으로 창이 닫힙니다.")
                        .font(.system(size: 12))
                        .foregroundColor(.textWhite)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.darkCard)
                
                CloudflareWebView { cookie in
                    onBypassSuccess()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("보안 캡차 우회")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonOrange)
                }
            }
        }
    }
}

struct CloudflareWebView: UIViewRepresentable {
    let onClearanceFound: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onClearanceFound: onClearanceFound)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = NetworkService.defaultUserAgent
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: "https://e621.net/posts") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let onClearanceFound: (String) -> Void
        private var timer: Timer?
        
        init(onClearanceFound: @escaping (String) -> Void) {
            self.onClearanceFound = onClearanceFound
            super.init()
        }
        
        deinit {
            timer?.invalidate()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            checkCookies(in: webView)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self, weak webView] _ in
                guard let webView = webView else { return }
                self?.checkCookies(in: webView)
            }
        }
        
        private func checkCookies(in webView: WKWebView) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
                for cookie in cookies {
                    if cookie.name == "cf_clearance" {
                        self?.timer?.invalidate()
                        let cookieValue = "\(cookie.name)=\(cookie.value)"
                        NetworkService.shared.updateCfClearance(cookieValue)
                        DispatchQueue.main.async {
                            self?.onClearanceFound(cookieValue)
                        }
                        return
                    }
                }
            }
        }
    }
}
