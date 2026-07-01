import AppKit
import Foundation
import Markdown

enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf
    case html
    case rtf

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pdf: "PDF"
        case .html: "HTML"
        case .rtf: "RTF"
        }
    }

    var fileExtension: String {
        rawValue
    }
}

enum ExportError: LocalizedError {
    case conversionFailed
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .conversionFailed:
            return "Could not convert document for export."
        case .writeFailed:
            return "Could not write exported file."
        }
    }
}

@MainActor
final class ExportService {
    private let renderer: MarkdownRenderer

    init(renderer: MarkdownRenderer = MarkdownRenderer()) {
        self.renderer = renderer
    }

    func export(content: String, format: ExportFormat, to url: URL) throws {
        switch format {
        case .html:
            let html = renderer.renderHTML(from: content)
            try html.write(to: url, atomically: true, encoding: .utf8)
        case .rtf:
            let html = renderer.renderHTML(from: content)
            let attributed = htmlToAttributedString(html: html)
            let range = NSRange(location: 0, length: attributed.length)
            guard let data = try? attributed.data(
                from: range,
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) else {
                throw ExportError.conversionFailed
            }
            try data.write(to: url, options: .atomic)
        case .pdf:
            let html = renderer.renderHTML(from: content)
            let attributed = htmlToAttributedString(html: html)
            try writePDF(from: attributed, to: url)
        }
    }

    private func htmlToAttributedString(html: String) -> NSAttributedString {
        guard let data = html.data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil
              ) else {
            return NSAttributedString(string: html)
        }
        return attributed
    }

    private func writePDF(from attributed: NSAttributedString, to url: URL) throws {
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 612, height: 792))
        textView.textStorage?.setAttributedString(attributed)
        textView.isEditable = false
        let pdfData = textView.dataWithPDF(inside: textView.bounds)
        do {
            try pdfData.write(to: url, options: .atomic)
        } catch {
            throw ExportError.writeFailed
        }
    }
}
