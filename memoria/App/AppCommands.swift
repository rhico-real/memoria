import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Import Files…") {
                appState.presentFileImporter()
            }
            Button("Import Folder…") {
                appState.presentFolderImporter()
            }
        }
        CommandGroup(after: .sidebar) {
            Button(appState.sidebarIsVisible ? "Hide Sidebar" : "Show Sidebar") {
                appState.toggleSidebarVisibility()
            }
            .keyboardShortcut("s", modifiers: [.command, .control])
        }
    }
}
