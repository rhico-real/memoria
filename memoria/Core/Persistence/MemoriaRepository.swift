import Foundation
import SQLite3

final nonisolated class MemoriaRepository: MemoriaRepositoryProtocol {
    private let database: MemoriaDatabase

    init(database: MemoriaDatabase) {
        self.database = database
    }

    func upsert(_ file: FileRecord) throws {
        let sql = """
        INSERT INTO files (
            id,
            source_path,
            file_name,
            file_extension,
            mime_type,
            size_bytes,
            created_at,
            modified_at,
            indexed_at,
            content_hash,
            media_kind,
            extraction_status
        ) VALUES (
            \(sqlQuoted(file.id.uuidString)),
            \(sqlQuoted(file.sourcePath)),
            \(sqlQuoted(file.fileName)),
            \(sqlQuoted(file.fileExtension)),
            \(sqlQuoted(file.mimeType)),
            \(file.sizeBytes),
            \(file.createdAt.timeIntervalSince1970),
            \(file.modifiedAt.timeIntervalSince1970),
            \(file.indexedAt.timeIntervalSince1970),
            \(sqlQuoted(file.contentHash)),
            \(sqlQuoted(file.mediaKind.rawValue)),
            \(sqlQuoted(file.extractionStatus.rawValue))
        )
        ON CONFLICT(id) DO UPDATE SET
            source_path = excluded.source_path,
            file_name = excluded.file_name,
            file_extension = excluded.file_extension,
            mime_type = excluded.mime_type,
            size_bytes = excluded.size_bytes,
            created_at = excluded.created_at,
            modified_at = excluded.modified_at,
            indexed_at = excluded.indexed_at,
            content_hash = excluded.content_hash,
            media_kind = excluded.media_kind,
            extraction_status = excluded.extraction_status;
        """

        try database.execute(sql)
    }

    func assignTag(named name: String, to fileID: UUID, kind: TagKind) throws {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let tagID = try upsertAndFetchTagID(name: normalizedName, kind: kind)

        let sql = """
        INSERT INTO file_tags (file_id, tag_id, confidence, source)
        VALUES (
            \(sqlQuoted(fileID.uuidString)),
            \(sqlQuoted(tagID.uuidString)),
            1.0,
            'local'
        )
        ON CONFLICT(file_id, tag_id) DO UPDATE SET
            confidence = excluded.confidence,
            source = excluded.source;
        """

        try database.execute(sql)
    }

    func tags(for fileID: UUID) throws -> [TagRecord] {
        let sql = """
        SELECT t.id, t.name, t.kind, t.source, t.created_at
        FROM tags t
        INNER JOIN file_tags ft ON ft.tag_id = t.id
        WHERE ft.file_id = \(sqlQuoted(fileID.uuidString))
        ORDER BY t.name COLLATE NOCASE ASC;
        """

        return try database.withStatement(sql) { statement in
            var results: [TagRecord] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                results.append(try self.mapTagRecord(from: statement))
            }
            return results
        }
    }

    func allFiles() throws -> [FileRecord] {
        let sql = """
        SELECT
            id,
            source_path,
            file_name,
            file_extension,
            mime_type,
            size_bytes,
            created_at,
            modified_at,
            indexed_at,
            content_hash,
            media_kind,
            extraction_status
        FROM files
        ORDER BY file_name COLLATE NOCASE ASC;
        """

        return try database.withStatement(sql) { statement in
            var results: [FileRecord] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                results.append(try self.mapFileRecord(from: statement))
            }
            return results
        }
    }

    private func upsertAndFetchTagID(name: String, kind: TagKind) throws -> UUID {
        let insertSQL = """
        INSERT INTO tags (id, name, kind, source, created_at)
        VALUES (
            \(sqlQuoted(UUID().uuidString)),
            \(sqlQuoted(name)),
            \(sqlQuoted(kind.rawValue)),
            'local',
            \(Date.now.timeIntervalSince1970)
        )
        ON CONFLICT(name, kind) DO NOTHING;
        """
        try database.execute(insertSQL)

        let selectSQL = """
        SELECT id
        FROM tags
        WHERE name = \(sqlQuoted(name))
          AND kind = \(sqlQuoted(kind.rawValue))
        LIMIT 1;
        """

        return try database.withStatement(selectSQL) { statement in
            guard sqlite3_step(statement) == SQLITE_ROW else {
                throw MemoriaDatabaseError.malformedRow
            }

            let value = try self.columnString(in: statement, at: 0)
            guard let id = UUID(uuidString: value) else {
                throw MemoriaDatabaseError.malformedRow
            }

            return id
        }
    }

    private func mapTagRecord(from statement: OpaquePointer) throws -> TagRecord {
        let idString = try columnString(in: statement, at: 0)
        let name = try columnString(in: statement, at: 1)
        let kindString = try columnString(in: statement, at: 2)
        let source = try columnString(in: statement, at: 3)
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 4))

        guard
            let id = UUID(uuidString: idString),
            let kind = TagKind(rawValue: kindString)
        else {
            throw MemoriaDatabaseError.malformedRow
        }

        return TagRecord(id: id, name: name, kind: kind, source: source, createdAt: createdAt)
    }

    private func mapFileRecord(from statement: OpaquePointer) throws -> FileRecord {
        let idString = try columnString(in: statement, at: 0)
        let sourcePath = try columnString(in: statement, at: 1)
        let fileName = try columnString(in: statement, at: 2)
        let fileExtension = try columnString(in: statement, at: 3)
        let mimeType = try columnString(in: statement, at: 4)
        let sizeBytes = sqlite3_column_int64(statement, 5)
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
        let modifiedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))
        let indexedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 8))
        let contentHash = try columnString(in: statement, at: 9)
        let mediaKindString = try columnString(in: statement, at: 10)
        let extractionStatusString = try columnString(in: statement, at: 11)

        guard
            let id = UUID(uuidString: idString),
            let mediaKind = MediaKind(rawValue: mediaKindString),
            let extractionStatus = ExtractionStatus(rawValue: extractionStatusString)
        else {
            throw MemoriaDatabaseError.malformedRow
        }

        return FileRecord(
            id: id,
            sourcePath: sourcePath,
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

    private func columnString(in statement: OpaquePointer, at index: Int32) throws -> String {
        guard let value = sqlite3_column_text(statement, index) else {
            throw MemoriaDatabaseError.malformedRow
        }
        return String(cString: value)
    }

    private func sqlQuoted(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "''") + "'"
    }
}
