import Foundation

enum MemoriaSchema {
    static let filesTable = """
    CREATE TABLE IF NOT EXISTS files (
        id TEXT PRIMARY KEY,
        source_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_extension TEXT NOT NULL,
        mime_type TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        created_at REAL NOT NULL,
        modified_at REAL NOT NULL,
        indexed_at REAL NOT NULL,
        content_hash TEXT NOT NULL,
        media_kind TEXT NOT NULL,
        extraction_status TEXT NOT NULL
    )
    """

    static let tagsTable = """
    CREATE TABLE IF NOT EXISTS tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        kind TEXT NOT NULL,
        source TEXT NOT NULL,
        created_at REAL NOT NULL,
        UNIQUE(name, kind)
    )
    """

    static let fileTagsTable = """
    CREATE TABLE IF NOT EXISTS file_tags (
        file_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        confidence REAL,
        source TEXT NOT NULL,
        PRIMARY KEY (file_id, tag_id),
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
    )
    """

    static let embeddingsTable = """
    CREATE TABLE IF NOT EXISTS embeddings (
        id TEXT PRIMARY KEY,
        file_id TEXT NOT NULL,
        modality TEXT NOT NULL,
        model_id TEXT NOT NULL,
        vector_blob BLOB NOT NULL,
        dimension INTEGER NOT NULL,
        created_at REAL NOT NULL,
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
    )
    """

    static let extractionArtifactsTable = """
    CREATE TABLE IF NOT EXISTS extraction_artifacts (
        id TEXT PRIMARY KEY,
        file_id TEXT NOT NULL UNIQUE,
        extracted_text TEXT NOT NULL,
        summary TEXT NOT NULL,
        detected_entities TEXT NOT NULL,
        analysis_json TEXT NOT NULL,
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
    )
    """

    static let modelRegistryTable = """
    CREATE TABLE IF NOT EXISTS model_registry (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        source TEXT NOT NULL,
        version TEXT NOT NULL,
        modality TEXT NOT NULL,
        local_path TEXT NOT NULL,
        checksum TEXT NOT NULL,
        loaded_at REAL NOT NULL
    )
    """

    static let statements: [String] = [
        filesTable,
        tagsTable,
        fileTagsTable,
        embeddingsTable,
        extractionArtifactsTable,
        modelRegistryTable
    ]
}
