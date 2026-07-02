import Foundation

enum IntroDemoContent {
    static let content = """
    # Hello

    Welcome to **LabWord** — **bold**, *italic*, `code` and [links](https://laborit.com.br).

    - [ ] something to do
    - [x] something done

    > Write without noise.

    ⌘, preferences · delete anytime
    """

    static func initialContent(showIntroDemo: Bool) -> String {
        showIntroDemo ? content : ""
    }
}
