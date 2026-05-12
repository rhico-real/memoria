import Foundation
import XCTest
@testable import memoria

final class IngestionServiceTests: XCTestCase {
    func testIngestingAFilePersistsAReferencedFileRecordWithoutCopying() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
        let sourceURL = temporaryDirectory.appendingPathComponent("notes.txt")
        try "crocodile notes".write(to: sourceURL, atomically: true, encoding: .utf8)

        let repository = StubRepository()
        let service = IngestionService(repository: repository)

        let records = try service.ingest(urls: [sourceURL])

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.sourcePath, canonicalPath(for: sourceURL))
        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertEqual(repository.files.map(\.sourcePath), [canonicalPath(for: sourceURL)])
    }

    func testIngestingAFolderRecursivelyPersistsReferencedFilesWithoutCopying() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
        let folderURL = temporaryDirectory.appendingPathComponent("import")
        let nestedFolderURL = folderURL.appendingPathComponent("nested")
        try FileManager.default.createDirectory(at: nestedFolderURL, withIntermediateDirectories: true)

        let firstFileURL = folderURL.appendingPathComponent("one.txt")
        let secondFileURL = nestedFolderURL.appendingPathComponent("two.txt")
        try "one".write(to: firstFileURL, atomically: true, encoding: .utf8)
        try "two".write(to: secondFileURL, atomically: true, encoding: .utf8)

        let repository = StubRepository()
        let service = IngestionService(repository: repository)

        let records = try service.ingest(urls: [folderURL])

        XCTAssertEqual(
            Set(records.map(\.sourcePath)),
            Set([canonicalPath(for: firstFileURL), canonicalPath(for: secondFileURL)])
        )
        XCTAssertEqual(
            Set(repository.files.map(\.sourcePath)),
            Set([canonicalPath(for: firstFileURL), canonicalPath(for: secondFileURL)])
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: firstFileURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: secondFileURL.path))
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }

    private func canonicalPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }
}
