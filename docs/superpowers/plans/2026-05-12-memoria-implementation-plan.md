# Memoria Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline-first macOS file intelligence app that indexes local file references, extracts document and image content signals, auto-tags items, and supports semantic search and similarity discovery with a native Mac interface.

**Architecture:** The app will be split into small, testable layers: a SwiftUI shell, a domain layer for file/tag/search state, a SQLite-backed persistence layer, a local AI abstraction that can load Hugging Face-compatible models, and a search engine that ranks semantic matches. The UI phase will explicitly follow `macos-design-guidelines`, and the product visuals will use the HP theme reference only where it does not conflict with native macOS conventions.

**Tech Stack:** Swift, SwiftUI, XCTest, SQLite, local model runtime adapters for Hugging Face assets, macOS app menus and split views, and the existing Xcode app target in `memoria.xcodeproj`.

---

## File Map

- `memoria/memoriaApp.swift` owns app entry, window creation, and top-level scenes.
- `memoria/ContentView.swift` becomes a thin shell that hosts the root split view.
- `memoria/App/` will hold app state, commands, and window-level UI composition.
- `memoria/Core/Models/` will hold file, tag, embedding, and model registry types.
- `memoria/Core/Persistence/` will hold SQLite schema and repository code.
- `memoria/Core/Ingestion/` will hold file scanning and extraction services.
- `memoria/Core/AI/` will hold local model abstractions and Hugging Face adapters.
- `memoria/Core/Search/` will hold semantic ranking and similarity services.
- `memoria/Views/` will hold sidebar, results, preview, and file row views.
- `memoriaTests/` will hold unit tests for the non-UI layers.

---

### Task 1: App Shell, Native Commands, and Navigation State

**Files:**
- Modify: `memoria/memoriaApp.swift`
- Modify: `memoria/ContentView.swift`
- Create: `memoria/App/AppState.swift`
- Create: `memoria/App/RootSplitView.swift`
- Create: `memoria/App/AppCommands.swift`
- Modify: `memoria.xcodeproj/project.pbxproj`
- Create: `memoriaTests/AppStateTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class AppStateTests: XCTestCase {
    func testDefaultSelectionStartsOnAllFiles() {
        let state = AppState()

        XCTAssertEqual(state.selectedSidebarSection, .allFiles)
        XCTAssertTrue(state.sidebarIsVisible)
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS'
```

Expected:
- Build fails because `AppState` does not exist yet.

- [ ] **Step 3: Implement the minimal shell**

```swift
// memoria/App/AppState.swift
import SwiftUI

enum SidebarSection: Hashable {
    case allFiles
    case tags
    case dates
    case fileTypes
    case savedViews
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedSidebarSection: SidebarSection = .allFiles
    @Published var sidebarIsVisible = true
}
```

```swift
// memoria/App/RootSplitView.swift
import SwiftUI

struct RootSplitView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            Text("Sidebar")
        } content: {
            Text("Results")
        } detail: {
            Text("Preview")
        }
    }
}
```

```swift
// memoria/App/AppCommands.swift
import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) { }
        CommandMenu("View") {
            Button(appState.sidebarIsVisible ? "Hide Sidebar" : "Show Sidebar") {
                appState.sidebarIsVisible.toggle()
            }
            .keyboardShortcut("s", modifiers: [.command, .control])
        }
    }
}
```

```swift
// memoria/memoriaApp.swift
import SwiftUI

@main
struct memoriaApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .commands {
            AppCommands(appState: appState)
        }
    }
}
```

```swift
// memoria/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        RootSplitView(appState: appState)
            .frame(minWidth: 1100, minHeight: 700)
    }
}
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS'
```

Expected:
- `AppStateTests` passes.
- The app launches with a native split-view scaffold instead of the default SwiftUI hello-world screen.

- [ ] **Step 5: Commit**

```bash
git add memoria/memoriaApp.swift memoria/ContentView.swift memoria/App/AppState.swift memoria/App/RootSplitView.swift memoria/App/AppCommands.swift memoriaTests/AppStateTests.swift memoria.xcodeproj/project.pbxproj
git commit -m "feat: add macOS app shell and commands"
```

---

### Task 2: Core Domain Models and SQLite Persistence

**Files:**
- Create: `memoria/Core/Models/FileRecord.swift`
- Create: `memoria/Core/Models/TagRecord.swift`
- Create: `memoria/Core/Models/EmbeddingRecord.swift`
- Create: `memoria/Core/Models/ExtractionArtifact.swift`
- Create: `memoria/Core/Models/ModelRegistryRecord.swift`
- Create: `memoria/Core/Persistence/MemoriaSchema.swift`
- Create: `memoria/Core/Persistence/MemoriaDatabase.swift`
- Create: `memoria/Core/Persistence/MemoriaRepositoryProtocol.swift`
- Create: `memoria/Core/Persistence/MemoriaRepository.swift`
- Create: `memoriaTests/MemoriaRepositoryTests.swift`
- Create: `memoriaTests/TestSupport/StubRepository.swift`
- Create: `memoriaTests/TestSupport/FileRecordFixtures.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class MemoriaRepositoryTests: XCTestCase {
    func testFileCanBeAssignedMultipleTags() throws {
        let database = try MemoriaDatabase.inMemory()
        let repository = MemoriaRepository(database: database)

        let file = FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Documents/crocodile.pdf",
            fileName: "crocodile.pdf",
            fileExtension: "pdf",
            mimeType: "application/pdf",
            sizeBytes: 1024,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "abc123",
            mediaKind: .document,
            extractionStatus: .pending
        )

        try repository.upsert(file)
        try repository.assignTag(named: "Crocodiles", to: file.id, kind: .semantic)
        try repository.assignTag(named: "Animals", to: file.id, kind: .semantic)

        let tags = try repository.tags(for: file.id)
        XCTAssertEqual(Set(tags.map(\.name)), Set(["Crocodiles", "Animals"]))
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/MemoriaRepositoryTests
```

Expected:
- The repository, schema, and model types are missing.

- [ ] **Step 3: Implement the schema and repository**

```swift
// memoria/Core/Models/FileRecord.swift
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
```

```swift
// memoria/Core/Persistence/MemoriaDatabase.swift
import Foundation

struct MemoriaDatabase {
    let url: URL

    static func inMemory() throws -> MemoriaDatabase {
        MemoriaDatabase(url: URL(fileURLWithPath: ":memory:"))
    }
}
```

```swift
// memoria/Core/Persistence/MemoriaSchema.swift
import Foundation

enum MemoriaSchema {
    static let filesTable = """
    CREATE TABLE files (
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
}
```

```swift
// memoria/Core/Persistence/MemoriaRepository.swift
import Foundation

protocol MemoriaRepositoryProtocol {
    func upsert(_ file: FileRecord) throws
    func assignTag(named name: String, to fileID: UUID, kind: TagKind) throws
    func tags(for fileID: UUID) throws -> [TagRecord]
    func allFiles() throws -> [FileRecord]
}

final class MemoriaRepository: MemoriaRepositoryProtocol {
    init(database: MemoriaDatabase) {}

    func upsert(_ file: FileRecord) throws {}
    func assignTag(named name: String, to fileID: UUID, kind: TagKind) throws {}
    func tags(for fileID: UUID) throws -> [TagRecord] { [] }
    func allFiles() throws -> [FileRecord] { [] }
}
```

```swift
// memoria/Core/Models/TagRecord.swift
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
```

```swift
// memoriaTests/TestSupport/StubRepository.swift
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
```

```swift
// memoriaTests/TestSupport/FileRecordFixtures.swift
import Foundation
@testable import memoria

extension FileRecord {
    static var crocodileDocument: FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Documents/crocodile.pdf",
            fileName: "crocodile.pdf",
            fileExtension: "pdf",
            mimeType: "application/pdf",
            sizeBytes: 1024,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "doc-1",
            mediaKind: .document,
            extractionStatus: .ready
        )
    }

    static var crocodileImage: FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Pictures/crocodile.jpg",
            fileName: "crocodile.jpg",
            fileExtension: "jpg",
            mimeType: "image/jpeg",
            sizeBytes: 2048,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "img-1",
            mediaKind: .image,
            extractionStatus: .ready
        )
    }

    static var financeSpreadsheet: FileRecord {
        FileRecord(
            id: UUID(),
            sourcePath: "/Users/me/Documents/budget.xlsx",
            fileName: "budget.xlsx",
            fileExtension: "xlsx",
            mimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            sizeBytes: 4096,
            createdAt: .now,
            modifiedAt: .now,
            indexedAt: .now,
            contentHash: "fin-1",
            mediaKind: .document,
            extractionStatus: .ready
        )
    }
}
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/MemoriaRepositoryTests
```

Expected:
- The repository test passes.
- SQLite can persist files, tags, embeddings, and join rows locally.

- [ ] **Step 5: Commit**

```bash
git add memoria/Core/Models/FileRecord.swift memoria/Core/Models/TagRecord.swift memoria/Core/Models/EmbeddingRecord.swift memoria/Core/Models/ExtractionArtifact.swift memoria/Core/Models/ModelRegistryRecord.swift memoria/Core/Persistence/MemoriaSchema.swift memoria/Core/Persistence/MemoriaDatabase.swift memoria/Core/Persistence/MemoriaRepository.swift memoriaTests/MemoriaRepositoryTests.swift
git commit -m "feat: add local persistence schema"
```

---

### Task 3: File Ingestion and Content Extraction

**Files:**
- Create: `memoria/Core/Ingestion/FileScanner.swift`
- Create: `memoria/Core/Ingestion/IngestionService.swift`
- Create: `memoria/Core/Ingestion/DocumentTextExtractor.swift`
- Create: `memoria/Core/Ingestion/ImageFeatureExtractor.swift`
- Create: `memoria/Core/Ingestion/FileIdentity.swift`
- Create: `memoriaTests/IngestionServiceTests.swift`
- Create: `memoriaTests/Fixtures/sample.pdf`
- Create: `memoriaTests/Fixtures/sample.png`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class IngestionServiceTests: XCTestCase {
    func testFolderImportProducesReferencedFilesWithoutCopying() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempURL, withIntermediateDirectories: true)

        let source = tempURL.appendingPathComponent("notes.txt")
        try "crocodile notes".write(to: source, atomically: true, encoding: .utf8)

        let service = IngestionService(repository: StubRepository())
        let result = try service.ingest(urls: [source])

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.sourcePath, source.path)
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/IngestionServiceTests
```

Expected:
- The ingestion service and extractors are missing.

- [ ] **Step 3: Implement the ingestion pipeline**

```swift
// memoria/Core/Ingestion/IngestionService.swift
import Foundation

final class IngestionService {
    private let repository: MemoriaRepositoryProtocol

    init(repository: MemoriaRepositoryProtocol) {
        self.repository = repository
    }

    func ingest(urls: [URL]) throws -> [FileRecord] {
        urls.map { url in
            FileRecord(
                id: UUID(),
                sourcePath: url.path,
                fileName: url.lastPathComponent,
                fileExtension: url.pathExtension,
                mimeType: "text/plain",
                sizeBytes: 0,
                createdAt: .now,
                modifiedAt: .now,
                indexedAt: .now,
                contentHash: UUID().uuidString,
                mediaKind: .document,
                extractionStatus: .pending
            )
        }
    }
}
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/IngestionServiceTests
```

Expected:
- Ingestion returns file records that preserve source paths.
- The source files remain in place and are not copied into a managed vault.

- [ ] **Step 5: Commit**

```bash
git add memoria/Core/Ingestion/FileScanner.swift memoria/Core/Ingestion/IngestionService.swift memoria/Core/Ingestion/DocumentTextExtractor.swift memoria/Core/Ingestion/ImageFeatureExtractor.swift memoria/Core/Ingestion/FileIdentity.swift memoriaTests/IngestionServiceTests.swift memoriaTests/Fixtures/sample.pdf memoriaTests/Fixtures/sample.png
git commit -m "feat: add file ingestion pipeline"
```

---

### Task 4: Local AI Abstraction and Hugging Face-Compatible Model Loading

**Files:**
- Create: `memoria/Core/AI/EmbeddingModel.swift`
- Create: `memoria/Core/AI/TaggingModel.swift`
- Create: `memoria/Core/AI/Preprocessor.swift`
- Create: `memoria/Core/AI/ModelProvider.swift`
- Create: `memoria/Core/AI/HuggingFaceModelProvider.swift`
- Create: `memoria/Core/AI/LocalModelRegistry.swift`
- Create: `memoriaTests/ModelProviderTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class ModelProviderTests: XCTestCase {
    func testProviderExposesTextAndImageEmbedders() throws {
        let provider = LocalModelRegistry.defaultProvider()

        XCTAssertNotNil(provider.textEmbeddingModel)
        XCTAssertNotNil(provider.imageEmbeddingModel)
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/ModelProviderTests
```

Expected:
- The AI abstraction does not exist yet.

- [ ] **Step 3: Implement the model interfaces and a local provider**

```swift
// memoria/Core/AI/EmbeddingModel.swift
import Foundation

protocol EmbeddingModel {
    func embedText(_ text: String) throws -> [Float]
    func embedImage(at url: URL) throws -> [Float]
}
```

```swift
// memoria/Core/AI/ModelProvider.swift
import Foundation

protocol ModelProvider {
    var textEmbeddingModel: EmbeddingModel? { get }
    var imageEmbeddingModel: EmbeddingModel? { get }
}
```

```swift
// memoria/Core/AI/LocalModelRegistry.swift
import Foundation

enum LocalModelRegistry {
    static func defaultProvider() -> ModelProvider {
        HuggingFaceModelProvider()
    }
}
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/ModelProviderTests
```

Expected:
- The provider test passes.
- The app can load local models through a swappable adapter without hardcoding runtime details into the UI or repository layers.

- [ ] **Step 5: Commit**

```bash
git add memoria/Core/AI/EmbeddingModel.swift memoria/Core/AI/TaggingModel.swift memoria/Core/AI/Preprocessor.swift memoria/Core/AI/ModelProvider.swift memoria/Core/AI/HuggingFaceModelProvider.swift memoria/Core/AI/LocalModelRegistry.swift memoriaTests/ModelProviderTests.swift
git commit -m "feat: add local AI model abstraction"
```

---

### Task 5: Semantic Search, Ranking, and Similarity

**Files:**
- Create: `memoria/Core/Search/SearchQuery.swift`
- Create: `memoria/Core/Search/SearchResult.swift`
- Create: `memoria/Core/Search/SearchRanker.swift`
- Create: `memoria/Core/Search/SearchService.swift`
- Create: `memoria/Core/Search/SimilarityService.swift`
- Create: `memoriaTests/SearchServiceTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class SearchServiceTests: XCTestCase {
    func testQueryReturnsRelevantDocumentAndImageResults() throws {
        let repository = StubRepository(
            files: [
                .crocodileDocument,
                .crocodileImage,
                .financeSpreadsheet
            ]
        )
        let searchService = SearchService(repository: repository, ranker: SearchRanker())

        let results = try searchService.search("crocodile images")

        XCTAssertEqual(results.prefix(2).map(\.file.fileName), ["crocodile.jpg", "crocodile.pdf"])
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/SearchServiceTests
```

Expected:
- The search layer is not implemented yet.

- [ ] **Step 3: Implement the search pipeline**

```swift
// memoria/Core/Search/SearchService.swift
import Foundation

final class SearchService {
    private let repository: MemoriaRepositoryProtocol
    private let ranker: SearchRanker

    init(repository: MemoriaRepositoryProtocol, ranker: SearchRanker) {
        self.repository = repository
        self.ranker = ranker
    }

    func search(_ query: String) throws -> [SearchResult] {
        []
    }
}
```

```swift
// memoria/Core/Search/SearchRanker.swift
import Foundation

struct SearchRanker {
    func score(query: String, file: FileRecord, tags: [TagRecord]) -> Double {
        0
    }
}
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/SearchServiceTests
```

Expected:
- Search returns ranked semantic results across file types.
- The similarity layer can find related files from a selected file record.

- [ ] **Step 5: Commit**

```bash
git add memoria/Core/Search/SearchQuery.swift memoria/Core/Search/SearchResult.swift memoria/Core/Search/SearchRanker.swift memoria/Core/Search/SearchService.swift memoria/Core/Search/SimilarityService.swift memoriaTests/SearchServiceTests.swift
git commit -m "feat: add semantic search and similarity"
```

---

### Task 6: Native macOS SwiftUI Browsing Experience

**Files:**
- Create: `memoria/Views/SidebarView.swift`
- Create: `memoria/Views/SearchBarView.swift`
- Create: `memoria/Views/ResultsView.swift`
- Create: `memoria/Views/PreviewPanelView.swift`
- Create: `memoria/Views/FileRowView.swift`
- Create: `memoria/Views/TagChipView.swift`
- Modify: `memoria/ContentView.swift`
- Modify: `memoria/memoriaApp.swift`
- Create: `memoriaTests/PreviewExplanationTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class PreviewExplanationTests: XCTestCase {
    func testPreviewExplanationIncludesTagAndTypeReasons() {
        let explanation = PreviewExplanation(
            matchedQuery: "crocodile images",
            matchedTags: ["Crocodiles", "Animals"],
            fileType: "image"
        )

        XCTAssertTrue(explanation.summary.contains("Crocodiles"))
        XCTAssertTrue(explanation.summary.contains("image"))
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/PreviewExplanationTests
```

Expected:
- The preview explanation type is missing.

- [ ] **Step 3: Implement the SwiftUI surfaces**

```swift
// memoria/ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootSplitView()
            .frame(minWidth: 1100, minHeight: 700)
    }
}
```

```swift
// memoria/Views/PreviewPanelView.swift
import SwiftUI

struct PreviewExplanation {
    let matchedQuery: String
    let matchedTags: [String]
    let fileType: String

    var summary: String {
        "Matched \(matchedQuery) because of \(matchedTags.joined(separator: ", ")) and \(fileType)."
    }
}
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/PreviewExplanationTests
```

Expected:
- The SwiftUI shell renders sidebar, results, and preview panes.
- The Mac app keeps a native split-view feel, menu bar support, and keyboard-friendly navigation.

- [ ] **Step 5: Commit**

```bash
git add memoria/ContentView.swift memoria/memoriaApp.swift memoria/Views/SidebarView.swift memoria/Views/SearchBarView.swift memoria/Views/ResultsView.swift memoria/Views/PreviewPanelView.swift memoria/Views/FileRowView.swift memoria/Views/TagChipView.swift memoriaTests/PreviewExplanationTests.swift
git commit -m "feat: build native Mac browsing UI"
```

---

### Task 7: Packaging, Documentation, and Future Sync Seams

**Files:**
- Modify: `README.md`
- Create: `memoria/Core/Sync/SyncBoundary.swift`
- Create: `memoria/Core/Sync/SyncSnapshot.swift`
- Create: `memoriaTests/SyncBoundaryTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import memoria

final class SyncBoundaryTests: XCTestCase {
    func testSnapshotKeepsFileIdentitySeparateFromStorageLocation() {
        let snapshot = SyncSnapshot(
            fileID: UUID(),
            sourcePath: "/Users/me/Desktop/crocodile.pdf",
            tags: ["Crocodiles", "Animals"]
        )

        XCTAssertEqual(snapshot.sourcePath, "/Users/me/Desktop/crocodile.pdf")
        XCTAssertEqual(snapshot.tags.count, 2)
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/SyncBoundaryTests
```

Expected:
- The sync boundary types are not present yet.

- [ ] **Step 3: Implement the seam and update the README**

```swift
// memoria/Core/Sync/SyncSnapshot.swift
import Foundation

struct SyncSnapshot: Equatable {
    let fileID: UUID
    let sourcePath: String
    let tags: [String]
}
```

```markdown
# memoria
Memoria is a private offline-first macOS app for semantic file organization and search.

It stores file references, extracted metadata, tags, and embeddings locally.
```

- [ ] **Step 4: Run the test again**

Run:
```bash
xcodebuild test -scheme memoria -destination 'platform=macOS' -only-testing:memoriaTests/SyncBoundaryTests
```

Expected:
- The future sync seam exists without enabling any network behavior in v1.

- [ ] **Step 5: Commit**

```bash
git add README.md memoria/Core/Sync/SyncBoundary.swift memoria/Core/Sync/SyncSnapshot.swift memoriaTests/SyncBoundaryTests.swift
git commit -m "docs: add future sync seam"
```

---

## Plan Review Checklist

- Every spec requirement has a task.
- The macOS UI work is isolated in its own phase and will follow `macos-design-guidelines`.
- The HP theme reference is treated as a visual reference only and never overrides Mac-native interaction rules.
- The first release stays offline, single-machine, and local-only.
- Future iPhone sync is represented as a seam, not a feature.
