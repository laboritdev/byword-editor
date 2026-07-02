import Foundation

enum DocumentComponentParser {
    private static let taskLinePattern = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+])\s+\[( |x|X)\](\s*)(.*)$"#,
        options: []
    )

    private static let bulletLinePattern = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+])\s+(?!\[)(.*)$"#,
        options: []
    )

    private static let numberedLinePattern = try! NSRegularExpression(
        pattern: #"^(\s*)(\d+)\.\s+(.*)$"#,
        options: []
    )

    private static let headingLinePattern = try! NSRegularExpression(
        pattern: #"^(#{1,6})\s+(.*)$"#,
        options: []
    )

    private static let blockquoteLinePattern = try! NSRegularExpression(
        pattern: #"^>\s?(.*)$"#,
        options: []
    )

    static func parse(_ text: String) -> [DocumentBlock] {
        guard !text.isEmpty else { return [] }

        var blocks: [DocumentBlock] = []
        var pendingList: ListGroupComponent?
        let lines = text.components(separatedBy: "\n")

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                pendingList = flushList(pendingList, into: &blocks)
                blocks.append(.line(.plain("")))
                continue
            }

            if let parsedListLine = parseListLine(line) {
                if var pending = pendingList, pending.matches(parsedListLine.group) {
                    pending.items.append(parsedListLine.item)
                    pendingList = pending
                } else {
                    pendingList = flushList(pendingList, into: &blocks)
                    pendingList = parsedListLine.group
                    pendingList?.items.append(parsedListLine.item)
                }
                continue
            }

            pendingList = flushList(pendingList, into: &blocks)
            blocks.append(.line(parseNonListLine(line)))
        }

        _ = flushList(pendingList, into: &blocks)
        return blocks
    }

    static func lineIndex(at location: Int, in text: String) -> Int? {
        guard location >= 0 else { return nil }
        let nsText = text as NSString

        if nsText.length == 0 {
            return 0
        }

        if location >= nsText.length {
            return max(0, text.components(separatedBy: "\n").count - 1)
        }

        if location == nsText.length - 1,
           nsText.substring(with: NSRange(location: location, length: 1)) == "\n",
           text.hasSuffix("\n") {
            return max(0, text.components(separatedBy: "\n").count - 1)
        }

        var index = 0
        var offset = 0
        while offset < nsText.length {
            let lineRange = nsText.lineRange(for: NSRange(location: offset, length: 0))
            let lineEnd = lineRange.location + lineRange.length
            if location >= lineRange.location, location < lineEnd {
                return index
            }
            if location == lineEnd && lineEnd == nsText.length {
                return index + 1
            }
            index += 1
            offset = lineEnd
            if lineRange.length == 0 { break }
        }
        return index
    }

    static func listContext(at lineIndex: Int, in blocks: [DocumentBlock]) -> (group: ListGroupComponent, itemIndex: Int)? {
        var currentLine = 0
        for block in blocks {
            switch block {
            case .line:
                if currentLine == lineIndex {
                    return nil
                }
                currentLine += 1
            case .list(let group):
                for itemIndex in group.items.indices {
                    if currentLine == lineIndex {
                        return (group, itemIndex)
                    }
                    currentLine += 1
                }
            }
        }
        return nil
    }

    private struct ParsedListLine {
        let group: ListGroupComponent
        let item: ListGroupItem
    }

    private static func parseListLine(_ line: String) -> ParsedListLine? {
        let nsLine = line as NSString
        let length = nsLine.length

        if let match = taskLinePattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let marker = Character(nsLine.substring(with: match.range(at: 2)))
            let checked = nsLine.substring(with: match.range(at: 3)) != " "
            let body = nsLine.substring(with: match.range(at: 5))
            let group = ListGroupComponent(indent: indent, kind: .task(marker: marker), items: [])
            return ParsedListLine(group: group, item: ListGroupItem(body: body, checked: checked))
        }

        if let match = bulletLinePattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let marker = Character(nsLine.substring(with: match.range(at: 2)))
            let body = nsLine.substring(with: match.range(at: 3))
            let group = ListGroupComponent(indent: indent, kind: .bullet(marker: marker), items: [])
            return ParsedListLine(group: group, item: ListGroupItem(body: body))
        }

        if let match = numberedLinePattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let body = nsLine.substring(with: match.range(at: 3))
            let group = ListGroupComponent(indent: indent, kind: .numbered, items: [])
            return ParsedListLine(group: group, item: ListGroupItem(body: body))
        }

        return nil
    }

    private static func parseNonListLine(_ line: String) -> DocumentLineComponent {
        let nsLine = line as NSString
        let length = nsLine.length

        if let match = headingLinePattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let level = nsLine.substring(with: match.range(at: 1)).count
            let text = nsLine.substring(with: match.range(at: 2))
            return .heading(level: level, text: text)
        }

        if let match = blockquoteLinePattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            return .blockquote(nsLine.substring(with: match.range(at: 1)))
        }

        return .plain(line)
    }

    @discardableResult
    private static func flushList(_ list: ListGroupComponent?, into blocks: inout [DocumentBlock]) -> ListGroupComponent? {
        guard let list, !list.items.isEmpty else { return nil }
        blocks.append(.list(list))
        return nil
    }
}

private extension ListGroupComponent {
    func matches(_ other: ListGroupComponent) -> Bool {
        indent == other.indent && kind == other.kind
    }
}
