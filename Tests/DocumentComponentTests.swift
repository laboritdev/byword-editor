import Testing
@testable import LabWordCore

@Suite("DocumentComponentParser")
struct DocumentComponentParserTests {
    @Test("groups consecutive numbered items")
    func numberedGroup() {
        let blocks = DocumentComponentParser.parse("1. first\n2. second\n3. third")
        #expect(blocks.count == 1)
        guard case .list(let group) = blocks[0] else {
            Issue.record("Expected list block")
            return
        }
        #expect(group.kind == .numbered)
        #expect(group.items.count == 3)
        #expect(group.items[0].body == "first")
        #expect(group.items[2].body == "third")
    }

    @Test("groups task list items")
    func taskGroup() {
        let blocks = DocumentComponentParser.parse("- [ ] todo\n- [x] done")
        #expect(blocks.count == 1)
        guard case .list(let group) = blocks[0] else {
            Issue.record("Expected list block")
            return
        }
        #expect(group.items[0].checked == false)
        #expect(group.items[1].checked == true)
    }

    @Test("splits list groups on blank lines")
    func blankLineBreaksList() {
        let blocks = DocumentComponentParser.parse("1. one\n\n2. two")
        #expect(blocks.count == 3)
        guard case .list(let first) = blocks[0],
              case .line(.plain("")) = blocks[1],
              case .list(let second) = blocks[2] else {
            Issue.record("Unexpected block layout")
            return
        }
        #expect(first.items.count == 1)
        #expect(second.items.count == 1)
    }
}

@Suite("DocumentStructureService")
struct DocumentStructureServiceTests {
    @Test("renumbers numbered lists after a gap")
    func renumberAfterGap() {
        let source = "1. te\n3. sada"
        let normalized = DocumentStructureService.normalize(source)
        #expect(normalized == "1. te\n2. sada")
    }

    @Test("renumbers after middle item removal")
    func renumberAfterDeletion() {
        let source = "1. one\n3. three"
        let normalized = DocumentStructureService.normalize(source)
        #expect(normalized == "1. one\n2. three")
    }

    @Test("preserves non-list content")
    func preservesPlainText() {
        let source = "Welcome\n\n1. item"
        let normalized = DocumentStructureService.normalize(source)
        #expect(normalized == source)
    }

    @Test("serializes bullet lists from components")
    func bulletSerialization() {
        let blocks: [DocumentBlock] = [
            .list(
                ListGroupComponent(
                    indent: "",
                    kind: .bullet(marker: "-"),
                    items: [ListGroupItem(body: "alpha"), ListGroupItem(body: "beta")]
                )
            ),
        ]
        let markdown = DocumentComponentSerializer.serialize(blocks)
        #expect(markdown == "- alpha\n- beta")
    }

    @Test("serializes empty task item without trailing body space")
    func emptyTaskSerialization() {
        let blocks: [DocumentBlock] = [
            .list(
                ListGroupComponent(
                    indent: "",
                    kind: .task(marker: "-"),
                    items: [ListGroupItem(body: "", checked: false)]
                )
            ),
        ]
        let markdown = DocumentComponentSerializer.serialize(blocks)
        #expect(markdown == "- [ ] ")
    }
}
