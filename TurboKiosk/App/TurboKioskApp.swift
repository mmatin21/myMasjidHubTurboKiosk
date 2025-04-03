//
//  TurboKioskApp.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI

@main
struct TurboKioskApp: App {
    // Create StateObjects for services that need to persist throughout the app lifecycle
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var kiosk = KioskStateManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .environmentObject(kiosk)
                .preferredColorScheme(.light) // Force light mode for kiosk
                .statusBar(hidden: true) // Hide status bar for kiosk experience
        }
    }
}
