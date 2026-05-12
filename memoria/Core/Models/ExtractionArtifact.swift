import Foundation

struct ExtractionArtifact: Identifiable, Codable, Equatable {
    let id: UUID
    let fileID: UUID
    let extractedText: String?
    let summary: String?
    let detectedEntities: [String]
    let analysisJSON: Data?
}
