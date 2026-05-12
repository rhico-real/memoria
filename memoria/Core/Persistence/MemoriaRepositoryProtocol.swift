import Foundation

protocol MemoriaRepositoryProtocol {
    func upsert(_ file: FileRecord) throws
    func assignTag(named name: String, to fileID: UUID, kind: TagKind) throws
    func tags(for fileID: UUID) throws -> [TagRecord]
    func allFiles() throws -> [FileRecord]
}
