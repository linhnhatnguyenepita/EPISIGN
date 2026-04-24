//
//  ContentView.swift
//  EPISIGN
//
//  Created by Nhat Linh on 24/04/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            if appState.isAuthenticated {
                switch appState.role {
                case .student:
                    StudentRootView()
                case .teacher:
                    TeacherRootView()
                }
            } else {
                AuthView()
            }
        }
        .environmentObject(appState)
        .animation(.easeInOut(duration: 0.25), value: appState.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
