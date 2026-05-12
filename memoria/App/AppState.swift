import Combine
import Foundation
import AppKit
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
    @Published var libraryFiles: [FileRecord] = []
    @Published var selectedFileID: FileRecord.ID?
    @Published var isPresentingFileImporter = false
    @Published var isPresentingFolderImporter = false
    @Published var importErrorMessage: String?

    private let repository: MemoriaRepositoryProtocol
    private let ingestionService: IngestionService

    init(
        repository: MemoriaRepositoryProtocol? = nil,
        ingestionService: IngestionService? = nil
    ) {
        let resolvedRepository = repository ?? AppState.makeDefaultRepository()
        self.repository = resolvedRepository
        self.ingestionService = ingestionService ?? IngestionService(repository: resolvedRepository)
        refreshLibrary()
    }

    func toggleSidebarVisibility() {
        sidebarIsVisible.toggle()
    }

    func presentFileImporter() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.resolvesAliases = true
        panel.title = "Import Files"
        panel.prompt = "Import"
        panel.begin { [weak self] response in
            guard response == .OK else { return }
            self?.importFiles(urls: panel.urls)
        }
    }

    func presentFolderImporter() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.resolvesAliases = true
        panel.title = "Import Folder"
        panel.prompt = "Import"
        panel.begin { [weak self] response in
            guard response == .OK else { return }
            self?.importFiles(urls: panel.urls)
        }
    }

    func importFiles(urls: [URL]) {
        do {
            let records = try ingestionService.ingest(urls: urls)
            refreshLibrary(selecting: records.first?.id)
        } catch {
            importErrorMessage = error.localizedDescription
        }
    }

    func dismissImportError() {
        importErrorMessage = nil
    }

    private func refreshLibrary(selecting selectedID: UUID? = nil) {
        libraryFiles = (try? repository.allFiles()) ?? []
        if let selectedID {
            selectedFileID = selectedID
        } else if selectedFileID == nil {
            selectedFileID = libraryFiles.first?.id
        }
    }

    private static func makeDefaultRepository() -> MemoriaRepositoryProtocol {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.memoria.macos.app.memoria"
        let appDirectory = supportDirectory.appendingPathComponent(bundleIdentifier, isDirectory: true)
        let databaseURL = appDirectory.appendingPathComponent("memoria.sqlite")

        do {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
            let database = try MemoriaDatabase(url: databaseURL)
            return MemoriaRepository(database: database)
        } catch {
            let database = try! MemoriaDatabase.inMemory()
            return MemoriaRepository(database: database)
        }
    }
}
