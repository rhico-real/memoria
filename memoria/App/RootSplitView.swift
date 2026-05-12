import SwiftUI

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
            List(selection: $appState.selectedSidebarSection) {
                Text("All Files").tag(SidebarSection.allFiles)
                Text("Tags").tag(SidebarSection.tags)
                Text("Dates").tag(SidebarSection.dates)
                Text("File Types").tag(SidebarSection.fileTypes)
                Text("Saved Views").tag(SidebarSection.savedViews)
            }
            .listStyle(.sidebar)
        } content: {
            Text("Results")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } detail: {
            Text("Preview")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
