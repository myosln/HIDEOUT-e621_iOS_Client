import Foundation
import WebKit

public class CloudflareHandler: NSObject, WKNavigationDelegate {
    public static let shared = CloudflareHandler()
    
    public var onClearanceFound: ((String) -> Void)?
    
    public func checkCookies(in webView: WKWebView) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { [weak self] cookies in
            for cookie in cookies {
                if cookie.name == "cf_clearance" {
                    let cookieHeader = "\(cookie.name)=\(cookie.value)"
                    NetworkService.shared.updateCfClearance(cookieHeader)
                    DispatchQueue.main.async {
                        self?.onClearanceFound?(cookieHeader)
                    }
                    return
                }
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        checkCookies(in: webView)
    }
}
