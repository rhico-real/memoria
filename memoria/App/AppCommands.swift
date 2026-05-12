import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) { }
        CommandGroup(after: .sidebar) {
            Button(appState.sidebarIsVisible ? "Hide Sidebar" : "Show Sidebar") {
                appState.toggleSidebarVisibility()
            }
            .keyboardShortcut("s", modifiers: [.command, .control])
        }
    }
}
