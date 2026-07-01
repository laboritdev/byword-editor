import Foundation

public struct DocumentSnapshot: Codable, Equatable, Identifiable {
    public let id: UUID
    public var fileURL: URL?
    public var content: String
    var cursorLocation: Int
    var selectionLength: Int
    var scrollOffset: Double
    var viewMode: ViewMode
    var isDirty: Bool

    public init(
        id: UUID = UUID(),
        fileURL: URL? = nil,
        content: String = "",
        cursorLocation: Int = 0,
        selectionLength: Int = 0,
        scrollOffset: Double = 0,
        viewMode: ViewMode = .editor,
        isDirty: Bool = false
    ) {
        self.id = id
        self.fileURL = fileURL
        self.content = content
        self.cursorLocation = cursorLocation
        self.selectionLength = selectionLength
        self.scrollOffset = scrollOffset
        self.viewMode = viewMode
        self.isDirty = isDirty
    }

    var displayTitle: String {
        if let fileURL {
            return fileURL.displayName
        }
        return "Untitled"
    }

    var fileExtension: String {
        fileURL?.pathExtension.lowercased() ?? "md"
    }
}

public struct SessionDocumentState: Codable, Equatable {
    public var fileURL: URL?
    public var recoveryID: UUID
    public var cursorLocation: Int
    public var selectionLength: Int
    public var scrollOffset: Double
    public var viewMode: ViewMode
}

public struct SessionState: Codable, Equatable {
    public var documents: [SessionDocumentState]
    public var savedAt: Date
}

struct RecoverySnapshot: Codable, Equatable {
    let recoveryID: UUID
    let fileURL: URL?
    let content: String
    let cursorLocation: Int
    let selectionLength: Int
    let scrollOffset: Double
    let viewMode: ViewMode
    let savedAt: Date
}
