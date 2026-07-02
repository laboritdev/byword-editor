import Foundation

struct BlockCursorMap {
    struct ListReference: Equatable {
        let blockIndex: Int
        let itemIndex: Int
        let group: ListGroupComponent
    }

    static func lineIndex(at location: Int, in text: String) -> Int? {
        DocumentComponentParser.lineIndex(at: location, in: text)
    }

    static func listReference(lineIndex: Int, in blocks: [DocumentBlock]) -> ListReference? {
        var currentLine = 0
        for (blockIndex, block) in blocks.enumerated() {
            guard case .list(let group) = block else {
                if currentLine == lineIndex { return nil }
                currentLine += 1
                continue
            }

            for itemIndex in group.items.indices {
                if currentLine == lineIndex {
                    return ListReference(blockIndex: blockIndex, itemIndex: itemIndex, group: group)
                }
                currentLine += 1
            }
        }
        return nil
    }

    static func cursorLocation(lineIndex: Int, offsetInLine: Int, in blocks: [DocumentBlock]) -> Int {
        let markdown = DocumentComponentSerializer.serialize(blocks)
        let maxOffset = (markdown as NSString).length
        var currentLine = 0
        var offset = 0

        for block in blocks {
            switch block {
            case .line(let line):
                let lineMarkdown = line.markdown
                if currentLine == lineIndex {
                    return min(offset + min(offsetInLine, lineMarkdown.utf16.count), maxOffset)
                }
                offset += lineMarkdown.utf16.count + 1
                currentLine += 1

            case .list(let group):
                for itemIndex in group.items.indices {
                    let lineMarkdown = group.markdownLines[itemIndex]
                    if currentLine == lineIndex {
                        return min(offset + min(offsetInLine, lineMarkdown.utf16.count), maxOffset)
                    }
                    offset += lineMarkdown.utf16.count + 1
                    currentLine += 1
                }
            }
        }

        return min(offset, maxOffset)
    }

    static func globalLineIndex(blockIndex: Int, itemIndex: Int, in blocks: [DocumentBlock]) -> Int {
        var currentLine = 0
        for (index, block) in blocks.enumerated() {
            if index == blockIndex {
                return currentLine + itemIndex
            }
            currentLine += block.lineCount
        }
        return currentLine
    }
}

struct BlockDocument: Equatable {
    private(set) var blocks: [DocumentBlock]

    init(markdown: String = "") {
        let repaired = ListLineRepairService.repair(markdown)
        blocks = DocumentComponentParser.parse(repaired)
    }

    var markdown: String {
        DocumentComponentSerializer.serialize(blocks)
    }

    mutating func applyEditedMarkdown(_ text: String) {
        let repaired = ListLineRepairService.repair(text)
        if structureMatches(repaired) {
            updateBodiesFromLines(repaired)
        } else {
            blocks = DocumentComponentParser.parse(repaired)
        }
    }

    mutating func syncFromEditorText(_ text: String) {
        applyEditedMarkdown(ListLineRepairService.repair(text))
    }

    mutating func handleEnter(at location: Int, in text: String) -> Int? {
        let repaired = ListLineRepairService.repair(text)
        syncFromEditorText(repaired)

        if let plainEnter = handleEnterOnPlainAfterList(at: location, in: repaired) {
            return plainEnter
        }

        guard let lineIndex = BlockCursorMap.lineIndex(at: location, in: repaired) else {
            return nil
        }

        if let reference = BlockCursorMap.listReference(lineIndex: lineIndex, in: blocks) {
            let lineStart = BlockCursorMap.cursorLocation(lineIndex: lineIndex, offsetInLine: 0, in: blocks)
            let cursorInLine = location - lineStart
            let line = reference.group.markdownLines[reference.itemIndex]
            guard let (marker, body) = ListLineMarkerAnalyzer.analyze(line: line) else {
                return nil
            }

            let bodyIsEmpty = body.trimmingCharacters(in: .whitespaces).isEmpty

            if marker.containsCursor(offsetInLine: cursorInLine) {
                if bodyIsEmpty {
                    return exitListItem(blockIndex: reference.blockIndex, itemIndex: reference.itemIndex)
                }
                return insertListItemAfter(blockIndex: reference.blockIndex, itemIndex: reference.itemIndex)
            }

            if bodyIsEmpty {
                return exitListItem(blockIndex: reference.blockIndex, itemIndex: reference.itemIndex)
            }

            return insertListItemAfter(blockIndex: reference.blockIndex, itemIndex: reference.itemIndex)
        }

        if let plainBlockIndex = plainBlockIndex(forLineIndex: lineIndex) {
            return insertPlainLineBreak(at: plainBlockIndex)
        }

        return nil
    }

    @discardableResult
    mutating func handleEnter(at location: Int) -> Int? {
        handleEnter(at: location, in: markdown)
    }

    mutating func insertTaskItem(at location: Int, checked: Bool = false) -> Int? {
        if let reference = listReference(at: location) {
            return insertTaskItem(
                blockIndex: reference.blockIndex,
                afterItemIndex: reference.itemIndex,
                checked: checked
            )
        }

        let item = ListGroupItem(body: "", checked: checked)
        let group = ListGroupComponent(indent: "", kind: .task(marker: "-"), items: [item])
        let blockIndex = insertionBlockIndex(for: location)
        blocks.insert(.list(group), at: blockIndex)

        let lineIndex = BlockCursorMap.globalLineIndex(blockIndex: blockIndex, itemIndex: 0, in: blocks)
        let prefixLength = group.prefixLength(forItemAt: 0)
        return BlockCursorMap.cursorLocation(lineIndex: lineIndex, offsetInLine: prefixLength, in: blocks)
    }

    mutating func toggleTaskCheckbox(at location: Int) -> Int? {
        guard let reference = listReference(at: location),
              case .task = reference.group.kind else {
            return nil
        }

        guard case .list(var group) = blocks[reference.blockIndex] else { return nil }
        group.items[reference.itemIndex].checked.toggle()
        blocks[reference.blockIndex] = .list(group)

        return location
    }

    private mutating func insertListItemAfter(blockIndex: Int, itemIndex: Int) -> Int {
        guard case .list(var group) = blocks[blockIndex] else { return 0 }

        let newItem: ListGroupItem
        switch group.kind {
        case .task:
            newItem = ListGroupItem(body: "", checked: false)
        default:
            newItem = ListGroupItem(body: "")
        }

        group.items.insert(newItem, at: itemIndex + 1)
        blocks[blockIndex] = .list(group)

        let lineIndex = BlockCursorMap.globalLineIndex(blockIndex: blockIndex, itemIndex: itemIndex + 1, in: blocks)
        let prefixLength = group.prefixLength(forItemAt: itemIndex + 1)
        return BlockCursorMap.cursorLocation(lineIndex: lineIndex, offsetInLine: prefixLength, in: blocks)
    }

    private mutating func insertPlainLineBreak(at blockIndex: Int) -> Int {
        blocks.insert(.line(.plain("")), at: blockIndex + 1)
        let blankLineIndex = lineIndex(forBlock: blockIndex + 1)
        return BlockCursorMap.cursorLocation(lineIndex: blankLineIndex, offsetInLine: 0, in: blocks)
    }

    private func plainBlockIndex(forLineIndex lineIndex: Int) -> Int? {
        var currentLine = 0
        for (blockIndex, block) in blocks.enumerated() {
            guard case .line(.plain) = block else {
                currentLine += block.lineCount
                continue
            }
            if currentLine == lineIndex {
                return blockIndex
            }
            currentLine += 1
        }
        return nil
    }

    private func lineIndex(forBlock blockIndex: Int) -> Int {
        blocks.prefix(blockIndex).reduce(0) { $0 + $1.lineCount }
    }

    private mutating func exitListItem(blockIndex: Int, itemIndex: Int) -> Int {
        guard case .list(var group) = blocks[blockIndex] else { return 0 }

        group.items.remove(at: itemIndex)

        if group.items.isEmpty {
            blocks[blockIndex] = .line(.plain(""))
            let blankLineIndex = lineIndex(forBlock: blockIndex)
            return BlockCursorMap.cursorLocation(lineIndex: blankLineIndex, offsetInLine: 0, in: blocks)
        }

        blocks[blockIndex] = .list(group)
        blocks.insert(.line(.plain("")), at: blockIndex + 1)

        let blankLineIndex = lineIndex(forBlock: blockIndex + 1)
        return BlockCursorMap.cursorLocation(lineIndex: blankLineIndex, offsetInLine: 0, in: blocks)
    }

    private mutating func handleEnterOnPlainAfterList(at location: Int, in text: String) -> Int? {
        guard blocks.count >= 2 else { return nil }
        guard case .list = blocks[blocks.count - 2],
              case .line(.plain) = blocks.last else {
            return nil
        }

        let plainBlockIndex = blocks.count - 1
        let plainLineIndex = lineIndex(forBlock: plainBlockIndex)
        guard BlockCursorMap.lineIndex(at: location, in: text) == plainLineIndex else {
            return nil
        }

        return insertPlainLineBreak(at: plainBlockIndex)
    }

    private mutating func insertTaskItem(
        blockIndex: Int,
        afterItemIndex itemIndex: Int,
        checked: Bool
    ) -> Int {
        guard case .list(var group) = blocks[blockIndex] else { return 0 }
        group.items.insert(ListGroupItem(body: "", checked: checked), at: itemIndex + 1)
        blocks[blockIndex] = .list(group)

        let lineIndex = BlockCursorMap.globalLineIndex(blockIndex: blockIndex, itemIndex: itemIndex + 1, in: blocks)
        let prefixLength = group.prefixLength(forItemAt: itemIndex + 1)
        return BlockCursorMap.cursorLocation(lineIndex: lineIndex, offsetInLine: prefixLength, in: blocks)
    }

    private func listReference(at location: Int) -> BlockCursorMap.ListReference? {
        guard let lineIndex = BlockCursorMap.lineIndex(at: location, in: markdown) else {
            return nil
        }
        return BlockCursorMap.listReference(lineIndex: lineIndex, in: blocks)
    }

    private func insertionBlockIndex(for location: Int) -> Int {
        guard let lineIndex = BlockCursorMap.lineIndex(at: location, in: markdown) else {
            return blocks.count
        }

        var currentLine = 0
        for (index, block) in blocks.enumerated() {
            let lineCount = block.lineCount
            if lineIndex <= currentLine + lineCount - 1 {
                return index + 1
            }
            currentLine += lineCount
        }

        return blocks.count
    }

    private func structureMatches(_ text: String) -> Bool {
        let parsed = DocumentComponentParser.parse(text)
        guard parsed.count == blocks.count else { return false }
        for (left, right) in zip(parsed, blocks) {
            if blockSignature(left) != blockSignature(right) {
                return false
            }
        }
        return true
    }

    private func blockSignature(_ block: DocumentBlock) -> String {
        switch block {
        case .line(let line):
            switch line {
            case .plain: "plain"
            case .heading(let level, _): "heading:\(level)"
            case .blockquote: "blockquote"
            }
        case .list(let group):
            switch group.kind {
            case .bullet(let marker): "bullet:\(group.indent):\(marker):\(group.items.count)"
            case .numbered: "numbered:\(group.indent):\(group.items.count)"
            case .task(let marker): "task:\(group.indent):\(marker):\(group.items.count)"
            }
        }
    }

    private mutating func updateBodiesFromLines(_ text: String) {
        let lines = text.components(separatedBy: "\n")
        var lineIndex = 0

        for blockIndex in blocks.indices {
            switch blocks[blockIndex] {
            case .line(let line):
                guard lineIndex < lines.count else { return }
                blocks[blockIndex] = .line(parseLine(lines[lineIndex], fallback: line))
                lineIndex += 1

            case .list(var group):
                for itemIndex in group.items.indices {
                    guard lineIndex < lines.count else { return }
                    if let parsed = parseListLine(lines[lineIndex], kind: group.kind) {
                        group.items[itemIndex].body = parsed.body
                        if case .task = group.kind {
                            group.items[itemIndex].checked = parsed.checked
                        }
                    }
                    lineIndex += 1
                }
                blocks[blockIndex] = .list(group)
            }
        }
    }

    private func parseLine(_ line: String, fallback: DocumentLineComponent) -> DocumentLineComponent {
        let parsed = DocumentComponentParser.parse(line)
        guard let first = parsed.first, case .line(let component) = first, parsed.count == 1 else {
            return fallback
        }
        return component
    }

    private func parseListLine(_ line: String, kind: ListGroupComponent.Kind) -> (body: String, checked: Bool)? {
        guard let (marker, body) = ListLineMarkerAnalyzer.analyze(line: line) else {
            return nil
        }

        let checked: Bool
        switch marker {
        case .task(_, _, let isChecked, _):
            checked = isChecked
        default:
            checked = false
        }

        switch kind {
        case .bullet:
            guard case .bullet = marker else { return nil }
        case .numbered:
            guard case .numbered = marker else { return nil }
        case .task:
            guard case .task = marker else { return nil }
        }

        return (body, checked)
    }
}
