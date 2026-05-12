import Foundation
import SQLite3

enum MemoriaDatabaseError: Error {
    case openFailed(path: String, code: Int32)
    case prepareFailed(message: String)
    case stepFailed(message: String)
    case executeFailed(message: String)
    case malformedRow
}

final nonisolated class MemoriaDatabase {
    let url: URL
    private var connection: OpaquePointer?

    init(url: URL, inMemory: Bool = false) throws {
        self.url = url

        var db: OpaquePointer?
        let path = inMemory ? ":memory:" : url.path
        let result = sqlite3_open(path, &db)
        guard result == SQLITE_OK, let db else {
            throw MemoriaDatabaseError.openFailed(path: url.path, code: result)
        }

        connection = db
        try execute("PRAGMA foreign_keys = ON")
        try createSchemaIfNeeded()
    }

    deinit {
        if let connection {
            sqlite3_close_v2(connection)
            self.connection = nil
        }
    }

    static func inMemory() throws -> MemoriaDatabase {
        try MemoriaDatabase(url: URL(fileURLWithPath: "/tmp/memoria-in-memory.sqlite"), inMemory: true)
    }

    func withStatement<T>(_ sql: String, _ work: (OpaquePointer) throws -> T) throws -> T {
        guard let connection else {
            throw MemoriaDatabaseError.openFailed(path: url.path, code: SQLITE_MISUSE)
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(connection, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw MemoriaDatabaseError.prepareFailed(message: lastErrorMessage())
        }
        defer { sqlite3_finalize(statement) }
        return try work(statement)
    }

    func execute(_ sql: String) throws {
        guard let connection else {
            throw MemoriaDatabaseError.openFailed(path: url.path, code: SQLITE_MISUSE)
        }
        guard sqlite3_exec(connection, sql, nil, nil, nil) == SQLITE_OK else {
            throw MemoriaDatabaseError.executeFailed(message: lastErrorMessage())
        }
    }

    func lastErrorMessage() -> String {
        guard let connection else {
            return "SQLite connection is closed"
        }
        guard let cString = sqlite3_errmsg(connection) else {
            return "Unknown SQLite error"
        }
        return String(cString: cString)
    }

    private func createSchemaIfNeeded() throws {
        for statement in MemoriaSchema.statements {
            try execute(statement)
        }
    }
}
