import Foundation
import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    @Binding var height: CGFloat
    
    let htmlString: String
    
    let showLink: (String) -> Void
    
    init(_ text: String, height: Binding<CGFloat>, showLink: @escaping (String) -> Void) {
        self.showLink = showLink
        self._height = height
        if let data = text.data(using: .utf8) {
            do {
                let attrStr = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                self.htmlString = attrStr.string
                return
            } catch {
                print(error)
            }
        }
        self.htmlString = ""
    }
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(showLink: showLink) { height in
            DispatchQueue.main.async {
                self.height = height
            }
        }
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let view = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.isOpaque = false;
        view.backgroundColor = UIColor.clear;
        view.navigationDelegate = context.coordinator
        return view
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, ObservableObject {
        let heightSetter: (CGFloat) -> Void
        let showLink: (String) -> Void
        
        init(showLink: @escaping (String) -> Void, heightSetter: @escaping (CGFloat) -> Void) {
            self.heightSetter = heightSetter
            self.showLink = showLink
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.readyState") { (complete, error) in
                if complete != nil {
                    webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                        self.heightSetter(height as! CGFloat)
                    })
                }
                
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if (navigationAction.navigationType == .linkActivated) {
                if let url = navigationAction.request.url, let host = url.host {
                    if host.contains("reddit.com") {
//                        print(url.path)
                        showLink(url.path)
                        decisionHandler(.cancel)
                        return
                    } else if (UIApplication.shared.canOpenURL(url)) {
                        UIApplication.shared.open(url)
                        decisionHandler(.cancel)
                        return
                    }
                }
            }
            decisionHandler(.allow)
        }
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let styleString = "<head><style>:root {color-scheme: light dark;} :root {font: -apple-system-body !important;}</style><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"></head>\(htmlString)"
        uiView.loadHTMLString(styleString, baseURL: URL(string: "https://www.reddit.com"))
    }
    
}
