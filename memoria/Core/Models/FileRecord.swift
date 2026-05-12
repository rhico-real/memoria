import Foundation

enum MediaKind: String, Codable {
    case document
    case image
}

enum ExtractionStatus: String, Codable {
    case pending
    case processing
    case ready
    case failed
}

struct FileRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let sourcePath: String
    let fileName: String
    let fileExtension: String
    let mimeType: String
    let sizeBytes: Int64
    let createdAt: Date
    let modifiedAt: Date
    let indexedAt: Date
    let contentHash: String
    let mediaKind: MediaKind
    let extractionStatus: ExtractionStatus
}
