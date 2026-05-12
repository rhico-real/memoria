import XCTest
@testable import memoria

@MainActor
final class MemoriaRepositoryTests: XCTestCase {
    func testFileCanBeAssignedMultipleTags() throws {
        let database = try MemoriaDatabase.inMemory()
        let repository = MemoriaRepository(database: database)

        let file = FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Documents/crocodile.pdf",
            fileName: "crocodile.pdf",
            fileExtension: "pdf",
            mimeType: "application/pdf",
            sizeBytes: 1024,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "abc123",
            mediaKind: .document,
            extractionStatus: .pending
        )

        try repository.upsert(file)
        try repository.assignTag(named: "Crocodiles", to: file.id, kind: .semantic)
        try repository.assignTag(named: "Animals", to: file.id, kind: .semantic)

        let tags = try repository.tags(for: file.id)
        XCTAssertEqual(Set(tags.map(\.name)), Set(["Crocodiles", "Animals"]))
    }
}
