//
//  JavaScriptBridge.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation
import WebKit

class JavaScriptBridge: NSObject {
    static func addBridgeToWebView(_ webView: WKWebView, messageHandler: WKScriptMessageHandler) {
        // Get bridge script
        let bridgeScript = ScriptInjector.getBridgeScript()
        
        // Create user script
        let userScript = WKUserScript(
            source: bridgeScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        // Add script to web view
        webView.configuration.userContentController.addUserScript(userScript)
        
        // Add message handler
        webView.configuration.userContentController.add(messageHandler, name: "kiosk")
    }
}
