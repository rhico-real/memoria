import CryptoKit
import Foundation
import UniformTypeIdentifiers

struct FileIdentity: Equatable {
    let url: URL
    let fileName: String
    let fileExtension: String
    let mimeType: String
    let sizeBytes: Int64
    let createdAt: Date
    let modifiedAt: Date
    let contentHash: String
    let mediaKind: MediaKind

    init(url: URL) throws {
        let normalizedURL = url.standardizedFileURL
        self.url = normalizedURL
        fileName = normalizedURL.lastPathComponent
        fileExtension = normalizedURL.pathExtension.lowercased()

        let values = try normalizedURL.resourceValues(forKeys: [
            .fileSizeKey,
            .creationDateKey,
            .contentModificationDateKey
        ])

        sizeBytes = Int64(values.fileSize ?? 0)
        createdAt = values.creationDate ?? .now
        modifiedAt = values.contentModificationDate ?? createdAt

        let type = UTType(filenameExtension: fileExtension)
        mimeType = type?.preferredMIMEType ?? "application/octet-stream"
        mediaKind = type?.conforms(to: .image) == true ? .image : .document
        contentHash = try FileIdentity.hash(for: normalizedURL)
    }

    func makeFileRecord(indexedAt: Date = .now, extractionStatus: ExtractionStatus = .pending) -> FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: url.path,
            fileName: fileName,
            fileExtension: fileExtension,
            mimeType: mimeType,
            sizeBytes: sizeBytes,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            indexedAt: indexedAt,
            contentHash: contentHash,
            mediaKind: mediaKind,
            extractionStatus: extractionStatus
        )
    }

    private static func hash(for url: URL) throws -> String {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
