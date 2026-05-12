//
//  memoriaApp.swift
//  memoria
//
//  Created by YAHSHUA Systech on 5/12/26.
//

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
