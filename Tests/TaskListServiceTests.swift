import Testing
@testable import LabWordCore

@Suite("TaskListService")
struct TaskListServiceTests {
    @Test("inserts unchecked checklist item")
    func insertTaskItem() {
        let result = TaskListService.insertTaskItem(in: "", at: 0)
        #expect(result.text == "- [ ] ")
        #expect(result.cursorLocation == 6)
    }

    @Test("toggles checkbox when clicking task marker")
    func toggleCheckboxOnMarker() {
        let source = "- [ ] Buy milk\n"
        let markerIndex = source.firstIndex(of: "-")!.utf16Offset(in: source)
        let toggled = TaskListService.toggleCheckbox(in: source, at: markerIndex)
        #expect(toggled?.text.contains("- [x] Buy milk") == true)
    }

    @Test("does not toggle when clicking task body")
    func ignoreBodyClick() {
        let source = "- [ ] Buy milk\n"
        let bodyIndex = source.firstIndex(of: "B")!.utf16Offset(in: source)
        let toggled = TaskListService.toggleCheckbox(in: source, at: bodyIndex)
        #expect(toggled == nil)
    }

    @Test("toggles checkbox between unchecked and checked")
    func toggleCheckbox() {
        let source = "- [ ] Buy milk\n"
        let checkboxIndex = source.firstIndex(of: "[")!.utf16Offset(in: source) + 1
        let toggled = TaskListService.toggleCheckbox(in: source, at: checkboxIndex)
        #expect(toggled?.text.contains("- [x] Buy milk") == true)

        let checkedIndex = toggled!.text.firstIndex(of: "x")!.utf16Offset(in: toggled!.text)
        let restored = TaskListService.toggleCheckbox(in: toggled!.text, at: checkedIndex)
        #expect(restored?.text.contains("- [ ] Buy milk") == true)
    }

    @Test("detects checked task lines")
    func checkedTaskLine() {
        #expect(TaskListService.isCheckedTaskLine("- [x] Done") == true)
        #expect(TaskListService.isCheckedTaskLine("- [ ] Todo") == false)
    }
}
