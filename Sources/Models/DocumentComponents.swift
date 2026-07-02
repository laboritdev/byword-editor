import Foundation

struct BulletListComponent: Equatable {
    let indent: String
    let marker: Character
}

struct TaskListComponent: Equatable {
    let indent: String
    let marker: Character
}

struct NumberedListComponent: Equatable {
    let indent: String
}

struct ListGroupItem: Equatable {
    var body: String
    var checked: Bool

    init(body: String, checked: Bool = false) {
        self.body = body
        self.checked = checked
    }
}

struct ListGroupComponent: Equatable {
    enum Kind: Equatable {
        case bullet(marker: Character)
        case numbered
        case task(marker: Character)
    }

    let indent: String
    let kind: Kind
    var items: [ListGroupItem]

    func prefixLength(forItemAt index: Int) -> Int {
        guard items.indices.contains(index) else { return 0 }
        let line = markdownLines[index]
        guard let (marker, _) = ListLineMarkerAnalyzer.analyze(line: line) else {
            return line.utf16.count
        }
        return marker.prefixLength
    }

    var markdownLines: [String] {
        items.enumerated().map { index, item in
            switch kind {
            case .bullet(let marker):
                if item.body.isEmpty {
                    return "\(indent)\(marker) "
                }
                return "\(indent)\(marker) \(item.body)"
            case .numbered:
                if item.body.isEmpty {
                    return "\(indent)\(index + 1). "
                }
                return "\(indent)\(index + 1). \(item.body)"
            case .task(let marker):
                let state = item.checked ? "x" : " "
                if item.body.isEmpty {
                    return "\(indent)\(marker) [\(state)] "
                }
                return "\(indent)\(marker) [\(state)] \(item.body)"
            }
        }
    }

    func continuationPrefix(afterItemAt index: Int) -> String {
        switch kind {
        case .bullet(let marker):
            "\n\(indent)\(marker) "
        case .numbered:
            "\n\(indent)\(index + 2). "
        case .task(let marker):
            "\n\(indent)\(marker) [ ] "
        }
    }
}

enum DocumentLineComponent: Equatable {
    case plain(String)
    case heading(level: Int, text: String)
    case blockquote(String)

    var markdown: String {
        switch self {
        case .plain(let content):
            content
        case .heading(let level, let text):
            String(repeating: "#", count: level) + " " + text
        case .blockquote(let text):
            "> " + text
        }
    }
}

enum DocumentBlock: Equatable {
    case line(DocumentLineComponent)
    case list(ListGroupComponent)

    var lineCount: Int {
        switch self {
        case .line:
            1
        case .list(let group):
            group.items.count
        }
    }
}

extension Array where Element == DocumentBlock {
    var totalLineCount: Int {
        reduce(0) { $0 + $1.lineCount }
    }
}
