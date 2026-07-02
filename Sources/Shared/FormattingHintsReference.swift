import Foundation

struct FormattingHint: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let syntax: String
    let description: String
}

enum FormattingHintsReference {
    static let sections: [(title: String, hints: [FormattingHint])] = [
        (
            "Structure",
            [
                FormattingHint(title: "Heading", syntax: "# Title", description: "Use 1–6 # symbols for heading levels."),
                FormattingHint(title: "Quote", syntax: "> Quote", description: "Prefix a line with > for blockquotes."),
                FormattingHint(title: "Divider", syntax: "---", description: "Three or more dashes on their own line."),
            ]
        ),
        (
            "Emphasis",
            [
                FormattingHint(title: "Bold", syntax: "**bold**", description: "Wrap text with double asterisks."),
                FormattingHint(title: "Italic", syntax: "*italic*", description: "Wrap text with single asterisks."),
                FormattingHint(title: "Code", syntax: "`code`", description: "Wrap inline code with backticks."),
            ]
        ),
        (
            "Lists",
            [
                FormattingHint(title: "Bullet", syntax: "- Item", description: "Start a line with -, *, or +."),
                FormattingHint(title: "Numbered", syntax: "1. Item", description: "Start a line with a number and period."),
                FormattingHint(
                    title: "Checklist",
                    syntax: "- [ ] Task",
                    description: "Click the checkbox in the editor to toggle done. Use - [x] for completed items."
                ),
            ]
        ),
        (
            "Links",
            [
                FormattingHint(title: "Link", syntax: "[label](https://url)", description: "Markdown link syntax."),
                FormattingHint(title: "Auto link", syntax: "<https://url>", description: "Angle brackets for bare URLs."),
            ]
        ),
    ]
}
