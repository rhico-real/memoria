import SwiftUI

struct AppCommands: Commands {
    let appState: AppState

    var body: some Commands {
        CommandMenu("View") {
            Button(appState.sidebarIsVisible ? "Hide Sidebar" : "Show Sidebar") {
                appState.sidebarIsVisible.toggle()
            }
            .keyboardShortcut("s", modifiers: [.command, .control])
        }
    }
}
