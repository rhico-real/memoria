import Combine
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
