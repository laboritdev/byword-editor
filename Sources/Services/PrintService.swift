import AppKit
import Foundation

@MainActor
final class PrintService {
    func print(content: String, title: String, renderer: MarkdownRenderer) {
        let html = renderer.renderHTML(from: content)
        guard let data = html.data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil
              ) else {
            return
        }

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 612, height: 792))
        textView.textStorage?.setAttributedString(attributed)
        textView.isEditable = false

        let printInfo = NSPrintInfo.shared.copy() as? NSPrintInfo ?? NSPrintInfo.shared
        printInfo.jobDisposition = .spool
        printInfo.horizontalPagination = .automatic
        printInfo.verticalPagination = .automatic

        let operation = NSPrintOperation(view: textView, printInfo: printInfo)
        operation.showsPrintPanel = true
        operation.showsProgressPanel = true
        operation.runModal(for: NSApp.keyWindow ?? NSApp.mainWindow ?? NSWindow(), delegate: nil, didRun: nil, contextInfo: nil)
        _ = title
    }
}
