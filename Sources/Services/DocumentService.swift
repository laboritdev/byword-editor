import Foundation
import os

public enum DocumentError: LocalizedError, Equatable {
    case unsupportedFileType
    case readFailed(URL)
    case writeFailed(URL)
    case fileNotFound(URL)

    public var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "This file type is not supported."
        case .readFailed(let url):
            return "Could not read file at \(url.path)."
        case .writeFailed(let url):
            return "Could not save file at \(url.path)."
        case .fileNotFound(let url):
            return "File not found at \(url.path)."
        }
    }
}

public final class DocumentService {
    public init() {}
    private let logger = Logger(subsystem: Constants.appName, category: "DocumentService")

    public func load(from url: URL) throws -> String {
        guard url.isSupportedTextFile else {
            throw DocumentError.unsupportedFileType
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentError.fileNotFound(url)
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            logger.error("Failed to read \(url.path, privacy: .public): \(error.localizedDescription)")
            throw DocumentError.readFailed(url)
        }
    }

    public func save(content: String, to url: URL) throws {
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            logger.error("Failed to write \(url.path, privacy: .public): \(error.localizedDescription)")
            throw DocumentError.writeFailed(url)
        }
    }

    func createNewFile(at url: URL, content: String = "") throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try save(content: content, to: url)
    }

    public func duplicate(source: URL, destination: URL) throws {
        let content = try load(from: source)
        try save(content: content, to: destination)
    }

    func move(from source: URL, to destination: URL) throws {
        let content = try load(from: source)
        try save(content: content, to: destination)
        try FileManager.default.removeItem(at: source)
    }
}
