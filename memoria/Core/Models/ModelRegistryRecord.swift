import Foundation

struct ModelRegistryRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let source: String
    let version: String
    let modality: EmbeddingModality
    let localPath: String
    let checksum: String
    let loadedAt: Date?
}
