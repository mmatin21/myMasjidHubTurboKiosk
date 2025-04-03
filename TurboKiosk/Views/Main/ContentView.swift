//
//  ContentView.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI
import StripeCore

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var kiosk: KioskStateManager
    
    var body: some View {
        ZStack {
            if kiosk.isConfiguring {
                KioskConfigView()
            } else if sessionManager.isAuthenticated {
                WebViewContainer(url: sessionManager.currentURL)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name(AppConstants.didTimeoutNotification))) { _ in
                        // Handle session timeout
                        sessionManager.logout()
                    }
            } else {
                LoginView()
            }
            
            // Overlay for payment processing
            if sessionManager.isProcessingPayment {
                PaymentView(
                    amount: sessionManager.paymentAmount,
                    fundraiserId: sessionManager.paymentFundraiserId,
                    onCompletion: { success in
                        sessionManager.isProcessingPayment = false
                        if success {
                            sessionManager.handlePaymentSuccess()
                        } else {
                            sessionManager.handlePaymentFailure()
                        }
                    }
                )
                .background(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            // Initialize Stripe
            StripeAPI.defaultPublishableKey = AppConstants.stripePublishableKey
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
            .environmentObject(KioskStateManager())
    }
}
