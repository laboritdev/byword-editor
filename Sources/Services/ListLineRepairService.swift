import Foundation

enum ListLineRepairService {
    private static let duplicateTaskPattern = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+])\s+\[ \]\s+\[(x|X)\]\s*(.*)$"#,
        options: []
    )

    private static let orphanedTaskPattern = try! NSRegularExpression(
        pattern: #"^\[( |x|X)\](\s*)(.*)$"#,
        options: []
    )

    static func repair(_ text: String) -> String {
        var lines = text.components(separatedBy: "\n")
        lines = repairDuplicateTaskPrefixes(lines)
        lines = mergeOrphanedTaskFragments(lines)
        return lines.joined(separator: "\n")
    }

    private static func repairDuplicateTaskPrefixes(_ lines: [String]) -> [String] {
        lines.map { line in
            let nsLine = line as NSString
            let length = nsLine.length
            guard let match = duplicateTaskPattern.firstMatch(
                in: line,
                options: [],
                range: NSRange(location: 0, length: length)
            ) else {
                return line
            }

            let indent = nsLine.substring(with: match.range(at: 1))
            let marker = nsLine.substring(with: match.range(at: 2))
            let state = nsLine.substring(with: match.range(at: 3))
            let body = nsLine.substring(with: match.range(at: 4))
            return taskMarkdown(indent: indent, marker: Character(marker), checked: state != " ", body: body)
        }
    }

    private static func mergeOrphanedTaskFragments(_ lines: [String]) -> [String] {
        var repaired: [String] = []

        for line in lines {
            if ListLineMarkerAnalyzer.isOrphanedTaskFragment(line),
               let lastIndex = repaired.indices.last,
               let (marker, body) = ListLineMarkerAnalyzer.analyze(line: repaired[lastIndex]),
               body.trimmingCharacters(in: .whitespaces).isEmpty,
               case .bullet(let indent, let markerChar, _) = marker,
               let orphan = parseOrphanedTask(line) {
                repaired[lastIndex] = taskMarkdown(
                    indent: indent,
                    marker: markerChar,
                    checked: orphan.checked,
                    body: orphan.body
                )
                continue
            }

            repaired.append(line)
        }

        return repaired
    }

    private static func parseOrphanedTask(_ line: String) -> (checked: Bool, body: String)? {
        let nsLine = line as NSString
        guard let match = orphanedTaskPattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: nsLine.length)
        ) else {
            return nil
        }
        let checked = nsLine.substring(with: match.range(at: 1)) != " "
        let body = nsLine.substring(with: match.range(at: 3))
        return (checked, body)
    }

    private static func taskMarkdown(indent: String, marker: Character, checked: Bool, body: String) -> String {
        let state = checked ? "x" : " "
        if body.isEmpty {
            return "\(indent)\(marker) [\(state)]"
        }
        return "\(indent)\(marker) [\(state)] \(body)"
    }
}
