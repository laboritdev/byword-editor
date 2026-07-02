import Foundation

enum ListLineMarker {
    case bullet(indent: String, marker: Character, prefixLength: Int)
    case task(indent: String, marker: Character, checked: Bool, prefixLength: Int)
    case numbered(indent: String, number: Int, prefixLength: Int)

    var indent: String {
        switch self {
        case .bullet(let indent, _, _), .task(let indent, _, _, _), .numbered(let indent, _, _):
            indent
        }
    }

    var continuationPrefix: String {
        switch self {
        case .bullet(let indent, let marker, _):
            "\n\(indent)\(marker) "
        case .task(let indent, let marker, _, _):
            "\n\(indent)\(marker) [ ] "
        case .numbered(let indent, let number, _):
            "\n\(indent)\(number + 1). "
        }
    }

    func containsCursor(offsetInLine: Int) -> Bool {
        offsetInLine < prefixLength
    }

    var prefixLength: Int {
        switch self {
        case .bullet(_, _, let length), .task(_, _, _, let length), .numbered(_, _, let length):
            length
        }
    }
}

enum ListLineMarkerAnalyzer {
    private static let taskPattern = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+])\s+\[( |x|X)\](\s*)(.*)$"#,
        options: []
    )

    private static let bulletPattern = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+])(\s+)(.*)$"#,
        options: []
    )

    private static let bulletMarkerOnlyPattern = try! NSRegularExpression(
        pattern: #"^(\s*)([-*+])$"#,
        options: []
    )

    private static let numberedPattern = try! NSRegularExpression(
        pattern: #"^(\s*)(\d+)\.(\s*)(.*)$"#,
        options: []
    )

    private static let orphanedTaskPattern = try! NSRegularExpression(
        pattern: #"^\[( |x|X)\](\s*)(.*)$"#,
        options: []
    )

    static func analyze(line: String) -> (marker: ListLineMarker, body: String)? {
        let nsLine = line as NSString
        let length = nsLine.length
        guard length > 0 else { return nil }

        if let match = taskPattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let marker = Character(nsLine.substring(with: match.range(at: 2)))
            let checked = nsLine.substring(with: match.range(at: 3)) != " "
            let body = nsLine.substring(with: match.range(at: 5))
            let prefixLength = match.range(at: 4).location + match.range(at: 4).length
            return (
                .task(indent: indent, marker: marker, checked: checked, prefixLength: prefixLength),
                body
            )
        }

        if let match = bulletPattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let marker = Character(nsLine.substring(with: match.range(at: 2)))
            let body = nsLine.substring(with: match.range(at: 4))
            let prefixLength = match.range(at: 3).location + match.range(at: 3).length
            return (
                .bullet(indent: indent, marker: marker, prefixLength: prefixLength),
                body
            )
        }

        if let match = bulletMarkerOnlyPattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let marker = Character(nsLine.substring(with: match.range(at: 2)))
            return (.bullet(indent: indent, marker: marker, prefixLength: length), "")
        }

        if let match = numberedPattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: length)) {
            let indent = nsLine.substring(with: match.range(at: 1))
            let number = Int(nsLine.substring(with: match.range(at: 2))) ?? 1
            let body = nsLine.substring(with: match.range(at: 4))
            let prefixLength = match.range(at: 3).location + match.range(at: 3).length
            return (
                .numbered(indent: indent, number: number, prefixLength: prefixLength),
                body
            )
        }

        return nil
    }

    static func isOrphanedTaskFragment(_ line: String) -> Bool {
        orphanedTaskPattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: (line as NSString).length)
        ) != nil
    }

    static func isBareBulletMarker(_ line: String) -> Bool {
        bulletMarkerOnlyPattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: (line as NSString).length)
        ) != nil
    }
}
