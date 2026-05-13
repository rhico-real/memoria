import SwiftUI
import UniformTypeIdentifiers

struct RootSplitView: View {
    @ObservedObject var appState: AppState

    private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { appState.sidebarIsVisible ? .all : .detailOnly },
            set: { appState.sidebarIsVisible = ($0 != .detailOnly) }
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: columnVisibilityBinding) {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image("MemoriaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    Text("Memoria")
                        .font(.headline.weight(.semibold))

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                List(selection: $appState.selectedSidebarSection) {
                    Text("All Files").tag(SidebarSection.allFiles)
                    Text("Tags").tag(SidebarSection.tags)
                    Text("Dates").tag(SidebarSection.dates)
                    Text("File Types").tag(SidebarSection.fileTypes)
                    Text("Saved Views").tag(SidebarSection.savedViews)
                }
                .listStyle(.sidebar)
            }
        } content: {
            VStack(spacing: 0) {
                HStack {
                    Text("Imported Files")
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Text("\(appState.libraryFiles.count) items")
                        .foregroundStyle(.secondary)
                }
                .padding()

                if appState.libraryFiles.isEmpty {
                    ContentUnavailableView(
                        "No files imported yet",
                        systemImage: "doc.badge.plus",
                        description: Text("Use Import Files or Import Folder to add local content.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $appState.selectedFileID) {
                        ForEach(appState.libraryFiles) { file in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(file.fileName)
                                    .font(.body.weight(.medium))
                                Text(file.sourcePath)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(file.id)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Import Files…") {
                        appState.presentFileImporter()
                    }
                    Button("Import Folder…") {
                        appState.presentFolderImporter()
                    }
                }
            }
            .dropDestination(for: URL.self) { urls, _ in
                appState.importFiles(urls: urls)
                return true
            }
        } detail: {
            Group {
                if let selectedFile = appState.libraryFiles.first(where: { $0.id == appState.selectedFileID }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedFile.fileName)
                            .font(.title2.weight(.semibold))
                        Text(selectedFile.sourcePath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Divider()
                        Text("This will become the file preview and match explanation panel.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                } else {
                    ContentUnavailableView(
                        "Select a file",
                        systemImage: "sidebar.left",
                        description: Text("Imported files appear here for preview and inspection.")
                    )
                }
            }
        }
        .alert(
            "Import Failed",
            isPresented: Binding(
                get: { appState.importErrorMessage != nil },
                set: { if !$0 { appState.dismissImportError() } }
            )
        ) {
            Button("OK", role: .cancel) {
                appState.dismissImportError()
            }
        } message: {
            Text(appState.importErrorMessage ?? "An unknown error occurred.")
        }
    }
}
