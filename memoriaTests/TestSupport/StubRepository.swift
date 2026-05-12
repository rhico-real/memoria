import Foundation
@testable import memoria

final class StubRepository: MemoriaRepositoryProtocol {
    var files: [FileRecord] = []
    var tagsByFileID: [UUID: [TagRecord]] = [:]

    init(files: [FileRecord] = []) {
        self.files = files
    }

    func upsert(_ file: FileRecord) throws {
        files.append(file)
    }

    func assignTag(named name: String, to fileID: UUID, kind: TagKind) throws {
        let tag = TagRecord(id: UUID(), name: name, kind: kind, source: "stub", createdAt: .now)
        tagsByFileID[fileID, default: []].append(tag)
    }

    func tags(for fileID: UUID) throws -> [TagRecord] {
        tagsByFileID[fileID, default: []]
    }

    func allFiles() throws -> [FileRecord] {
        files
    }
}
