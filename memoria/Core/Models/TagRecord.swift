import Foundation

enum TagKind: String, Codable {
    case semantic
    case metadata
    case manual
}

struct TagRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let kind: TagKind
    let source: String
    let createdAt: Date
}
