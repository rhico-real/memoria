import Foundation

enum EmbeddingModality: String, Codable {
    case text
    case image
}

struct EmbeddingRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let fileID: UUID
    let modality: EmbeddingModality
    let modelID: String
    let vector: Data
    let dimension: Int
    let createdAt: Date
}
