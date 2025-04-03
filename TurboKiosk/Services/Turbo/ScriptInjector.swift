//
//  ScriptInjector.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation

class ScriptInjector {
    static func getBridgeScript() -> String {
        // Try to load from file
        if let scriptPath = Bundle.main.path(forResource: "JavaScriptBridge", ofType: "js"),
           let scriptContent = try? String(contentsOfFile: scriptPath) {
            return scriptContent
        }
        
        // Fallback to hardcoded script
        return """
        // Register a custom message handler
        window.nativeApp = {
            sendMessage: function(message) {
                window.webkit.messageHandlers.kiosk.postMessage(message);
            },
            
            authenticate: function(token) {
                this.sendMessage({ action: 'authenticate', token: token });
            },
            
            processPayment: function(paymentData) {
                this.sendMessage({ action: 'processPayment', paymentData: paymentData });
            }
        };

        // Automatically capture authentication tokens from the page
        document.addEventListener('DOMContentLoaded', function() {
            // Look for authentication tokens from API responses
            if (window.kioskToken) {
                window.nativeApp.authenticate(window.kioskToken);
            }
            
            // Intercept form submissions for donation forms
            document.addEventListener('submit', function(event) {
                if (event.target.id === 'donation-form') {
                    event.preventDefault();
                    
                    // Get form data
                    const form = event.target;
                    const amount = form.amount.value;
                    const fundraiserId = form.fundraiser_id.value;
                    
                    // Send to native app for processing
                    window.nativeApp.processPayment({
                        amount: amount,
                        fundraiserId: fundraiserId
                    });
                }
            });
        });
        
        // Re-attach listeners after Turbo navigation
        document.addEventListener('turbo:load', function() {
            // Re-attach form listeners after page load
            document.querySelectorAll('#donation-form').forEach(function(form) {
                form.addEventListener('submit', function(event) {
                    event.preventDefault();
                    
                    // Get form data
                    const amount = form.amount.value;
                    const fundraiserId = form.fundraiser_id.value;
                    
                    // Send to native app for processing
                    window.nativeApp.processPayment({
                        amount: amount,
                        fundraiserId: fundraiserId
                    });
                });
            });
        });
        """
    }
}
