import Foundation

enum ListContinuationService {
    static func handleEnter(in document: inout BlockDocument, at location: Int, text: String) -> Int? {
        document.handleEnter(at: location, in: text)
    }
}
