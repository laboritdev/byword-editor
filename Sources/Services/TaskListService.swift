import Foundation

struct TaskListEditResult: Equatable {
    let text: String
    let cursorLocation: Int
}

enum TaskListService {
    private static let taskLinePattern = try! NSRegularExpression(
        pattern: #"^(\s*[-*+]\s+\[)( |x|X)(\])"#,
        options: []
    )

    private static let checkboxPattern = try! NSRegularExpression(
        pattern: #"\[( |x|X)\]"#,
        options: []
    )

    static func lineRange(in text: String, at location: Int) -> NSRange? {
        let nsText = text as NSString
        guard nsText.length > 0 else { return nil }
        let safeLocation = min(max(0, location), nsText.length)
        return nsText.lineRange(for: NSRange(location: safeLocation, length: 0))
    }

    static func checkboxCharacterRange(in text: String, at location: Int) -> NSRange? {
        guard let lineRange = lineRange(in: text, at: location) else { return nil }
        let line = (text as NSString).substring(with: lineRange)
        let lineStart = lineRange.location

        guard let taskMatch = taskLinePattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: (line as NSString).length)
        ) else { return nil }

        guard let checkboxMatch = checkboxPattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: (line as NSString).length)
        ) else { return nil }

        let checkboxRange = NSRange(
            location: lineStart + checkboxMatch.range.location,
            length: checkboxMatch.range.length
        )
        guard location >= checkboxRange.location,
              location < checkboxRange.location + checkboxRange.length else { return nil }
        return checkboxRange
    }

    static func toggleCheckbox(in text: String, at location: Int) -> TaskListEditResult? {
        guard let lineRange = lineRange(in: text, at: location) else { return nil }

        let nsText = text as NSString
        let line = nsText.substring(with: lineRange)
        let lineLength = (line as NSString).length
        guard let match = taskLinePattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: lineLength)
        ) else { return nil }

        let prefixEnd = match.range(at: 3).location + match.range(at: 3).length
        let clickOffset = location - lineRange.location
        guard clickOffset >= 0, clickOffset <= prefixEnd else { return nil }

        let stateRange = match.range(at: 2)
        let currentState = (line as NSString).substring(with: stateRange)
        let nextState = currentState == " " ? "x" : " "
        let updatedLine = (line as NSString).replacingCharacters(in: stateRange, with: nextState)
        let updatedText = nsText.replacingCharacters(in: lineRange, with: updatedLine)
        let cursor = lineRange.location + min(clickOffset, updatedLine.count)
        return TaskListEditResult(text: updatedText, cursorLocation: cursor)
    }

    static func insertTaskItem(in text: String, at location: Int, checked: Bool = false) -> TaskListEditResult {
        let marker = checked ? "- [x] " : "- [ ] "
        let nsText = text as NSString
        let safeLocation = min(max(0, location), nsText.length)
        let lineRange = nsText.lineRange(for: NSRange(location: safeLocation, length: 0))
        let isEmptyLine = nsText.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let prefix = isEmptyLine ? "" : "\n"
        let snippet = "\(prefix)\(marker)"
        let insertRange = NSRange(location: safeLocation, length: 0)
        let updatedText = nsText.replacingCharacters(in: insertRange, with: snippet)
        return TaskListEditResult(
            text: updatedText,
            cursorLocation: safeLocation + (snippet as NSString).length
        )
    }

    static func isCheckedTaskLine(_ line: String) -> Bool {
        taskLinePattern.firstMatch(
            in: line,
            options: [],
            range: NSRange(location: 0, length: (line as NSString).length)
        )
        .map { (line as NSString).substring(with: $0.range(at: 2)) != " " } ?? false
    }
}
