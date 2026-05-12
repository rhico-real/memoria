import XCTest
@testable import memoria

final class AppStateTests: XCTestCase {
    func testDefaultSelectionStartsOnAllFiles() async {
        let defaults = await MainActor.run { () -> (SidebarSection, Bool) in
            let state = AppState()
            return (state.selectedSidebarSection, state.sidebarIsVisible)
        }

        if defaults.0 != .allFiles {
            XCTFail("Expected default section to be .allFiles")
        }

        if !defaults.1 {
            XCTFail("Expected sidebar to be visible by default")
        }
    }
}
