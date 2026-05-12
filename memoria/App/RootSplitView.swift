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
