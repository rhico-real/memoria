//
//  ContentView.swift
//  memoria
//
//  Created by YAHSHUA Systech on 5/12/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        RootSplitView(appState: appState)
            .frame(minWidth: 1100, minHeight: 700)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
