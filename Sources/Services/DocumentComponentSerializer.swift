import Foundation

enum DocumentComponentSerializer {
    static func serialize(_ blocks: [DocumentBlock]) -> String {
        var lines: [String] = []
        for block in blocks {
            switch block {
            case .line(let line):
                lines.append(line.markdown)
            case .list(let group):
                lines.append(contentsOf: group.markdownLines)
            }
        }
        return lines.joined(separator: "\n")
    }
}
