import Foundation

enum NumberedListRenumberService {
    private static let numberedLinePattern = try! NSRegularExpression(
        pattern: #"^(\s*)(\d+)\.(\s*)(.*)$"#,
        options: []
    )

    static func renumber(in text: String) -> String {
        var lines = text.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            guard let group = numberedGroup(at: index, in: lines) else {
                index += 1
                continue
            }

            for offset in 0..<group.bodies.count {
                let lineIndex = group.start + offset
                lines[lineIndex] = numberedLine(
                    indent: group.indent,
                    index: offset + 1,
                    body: group.bodies[offset]
                )
            }

            index = group.start + group.bodies.count
        }

        return lines.joined(separator: "\n")
    }

    private struct NumberedGroup {
        let start: Int
        let indent: String
        let bodies: [String]
    }

    private static func numberedGroup(at index: Int, in lines: [String]) -> NumberedGroup? {
        guard index < lines.count, let first = parseNumberedLine(lines[index]) else {
            return nil
        }

        var bodies = [first.body]
        var next = index + 1
        while next < lines.count {
            if lines[next].trimmingCharacters(in: .whitespaces).isEmpty {
                break
            }
            guard let parsed = parseNumberedLine(lines[next]), parsed.indent == first.indent else {
                break
            }
            bodies.append(parsed.body)
            next += 1
        }

        return NumberedGroup(start: index, indent: first.indent, bodies: bodies)
    }

    private static func parseNumberedLine(_ line: String) -> (indent: String, body: String)? {
        let nsLine = line as NSString
        let length = nsLine.length
        guard let match = numberedLinePattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: length)
        ) else {
            return nil
        }

        return (
            indent: nsLine.substring(with: match.range(at: 1)),
            body: nsLine.substring(with: match.range(at: 4))
        )
    }

    private static func numberedLine(indent: String, index: Int, body: String) -> String {
        if body.isEmpty {
            return "\(indent)\(index). "
        }
        return "\(indent)\(index). \(body)"
    }
}
