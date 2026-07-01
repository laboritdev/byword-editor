import Foundation
import Markdown

public final class MarkdownRenderer {
    public init() {}

    public func renderHTML(from markdown: String) -> String {
        let document = Document(parsing: markdown)
        var visitor = HTMLVisitor()
        return visitor.visit(document)
    }
}

private struct HTMLVisitor: MarkupVisitor {
    mutating func defaultVisit(_ markup: Markup) -> String {
        markup.children.map { visit($0) }.joined()
    }

    mutating func visitDocument(_ document: Document) -> String {
        let body = defaultVisit(document)
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "New York", serif; line-height: 1.6; max-width: 680px; margin: 2rem auto; padding: 0 1rem; color: #222; }
        pre { background: #f5f5f5; padding: 1rem; overflow-x: auto; border-radius: 4px; }
        code { font-family: Menlo, monospace; font-size: 0.9em; }
        blockquote { border-left: 3px solid #ccc; margin-left: 0; padding-left: 1rem; color: #555; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 0.5rem; text-align: left; }
        img { max-width: 100%; }
        hr { border: none; border-top: 1px solid #ddd; margin: 2rem 0; }
        </style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        let level = min(max(heading.level, 1), 6)
        return "<h\(level)>\(defaultVisit(heading))</h\(level)>\n"
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        "<p>\(defaultVisit(paragraph))</p>\n"
    }

    mutating func visitText(_ text: Text) -> String {
        escapeHTML(text.plainText)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        "<em>\(defaultVisit(emphasis))</em>"
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        "<strong>\(defaultVisit(strong))</strong>"
    }

    mutating func visitLink(_ link: Link) -> String {
        let destination = escapeHTML(link.destination ?? "")
        return "<a href=\"\(destination)\">\(defaultVisit(link))</a>"
    }

    mutating func visitImage(_ image: Image) -> String {
        let source = escapeHTML(image.source ?? "")
        let alt = escapeHTML(image.plainText)
        return "<img src=\"\(source)\" alt=\"\(alt)\">"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        "<code>\(escapeHTML(inlineCode.code))</code>"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let language = codeBlock.language.map { " class=\"language-\(escapeHTML($0))\"" } ?? ""
        return "<pre><code\(language)>\(escapeHTML(codeBlock.code))</code></pre>\n"
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        "<blockquote>\(defaultVisit(blockQuote))</blockquote>\n"
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        "<ul>\(defaultVisit(unorderedList))</ul>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        "<ol>\(defaultVisit(orderedList))</ol>\n"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        "<li>\(defaultVisit(listItem))</li>\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        "<hr>\n"
    }

    mutating func visitTable(_ table: Table) -> String {
        var html = "<table>\n"
        let rows = Array(table.children)
        for (index, row) in rows.enumerated() {
            guard let tableRow = row as? Table.Row else { continue }
            html += "<tr>"
            for cell in tableRow.children {
                guard let tableCell = cell as? Table.Cell else { continue }
                let tag = index == 0 ? "th" : "td"
                html += "<\(tag)>\(visit(tableCell))</\(tag)>"
            }
            html += "</tr>\n"
        }
        html += "</table>\n"
        return html
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        "\n"
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        "<br>\n"
    }

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
