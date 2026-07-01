import SwiftUI
import WebKit

struct MarkdownPreviewView: View {
    let html: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        PreviewWebView(html: styledHTML)
            .background(Color(nsColor: .textBackgroundColor))
    }

    private var styledHTML: String {
        let background = colorScheme == .dark ? "#1c1c1e" : "#fafaf9"
        let text = colorScheme == .dark ? "#e0e0e3" : "#222222"
        return html.replacingOccurrences(
            of: "color: #222;",
            with: "color: \(text); background: \(background);"
        )
    }
}

private struct PreviewWebView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
