//
//  WebViewContainer.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI
import WebKit
import Turbo

struct WebViewContainer: View {
    @EnvironmentObject var sessionManager: SessionManager
    var url: URL
    
    var body: some View {
        TurboWebView(
            url: url,
            navigationDelegate: sessionManager.navigationDelegate,
            webViewConfiguration: sessionManager.webViewConfiguration
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Reset the session timeout when view appears
            sessionManager.resetSessionTimeout()
        }
        // Track user interaction to reset timeout
        .onTapGesture {
            sessionManager.resetSessionTimeout()
        }
    }
}
