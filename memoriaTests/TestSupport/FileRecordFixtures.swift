import Foundation
@testable import memoria

extension FileRecord {
    static var crocodileDocument: FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Documents/crocodile.pdf",
            fileName: "crocodile.pdf",
            fileExtension: "pdf",
            mimeType: "application/pdf",
            sizeBytes: 1024,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "doc-1",
            mediaKind: .document,
            extractionStatus: .ready
        )
    }

    static var crocodileImage: FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Pictures/crocodile.jpg",
            fileName: "crocodile.jpg",
            fileExtension: "jpg",
            mimeType: "image/jpeg",
            sizeBytes: 2048,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "img-1",
            mediaKind: .image,
            extractionStatus: .ready
        )
    }

    static var financeSpreadsheet: FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Documents/budget.xlsx",
            fileName: "budget.xlsx",
            fileExtension: "xlsx",
            mimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            sizeBytes: 4096,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "fin-1",
            mediaKind: .document,
            extractionStatus: .ready
        )
    }
}
