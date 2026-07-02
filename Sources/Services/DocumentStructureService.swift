import Foundation

enum DocumentStructureService {
    static func normalize(_ text: String) -> String {
        let repaired = ListLineRepairService.repair(text)
        return NumberedListRenumberService.renumber(in: repaired)
    }

    static func normalizePreservingCursor(in text: String, cursor: Int) -> (text: String, cursor: Int) {
        let normalized = normalize(text)
        guard normalized != text else {
            return (text, cursor)
        }
        let mappedCursor = mapCursor(from: text, to: normalized, cursor: cursor)
        return (normalized, mappedCursor)
    }

    static func mapCursor(from source: String, to target: String, cursor: Int) -> Int {
        let nsSource = source as NSString
        let nsTarget = target as NSString
        let safeCursor = min(max(0, cursor), nsSource.length)
        let anchorStart = max(0, safeCursor - 40)
        let anchorLength = safeCursor - anchorStart
        guard anchorLength > 0 else {
            return min(safeCursor, nsTarget.length)
        }

        let anchor = nsSource.substring(with: NSRange(location: anchorStart, length: anchorLength))
        let range = nsTarget.range(of: anchor, options: .backwards)
        guard range.location != NSNotFound else {
            return min(safeCursor, nsTarget.length)
        }
        return range.location + range.length
    }
}
