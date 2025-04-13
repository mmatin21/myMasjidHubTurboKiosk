//
//  PaymentView.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI
import Stripe
import StripePaymentSheet

struct PaymentView: View {
    @StateObject private var paymentHandler = CardPaymentHandler()
    let amount: Double
    let fundraiserId: String
    let onCompletion: (Bool) -> Void
    
    @State private var isShowingSheet = false
    @State private var isProcessing = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Payment Processing")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Amount: \(CurrencyFormatter.format(amount))")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                
                if isProcessing {
                    ProcessingView()
                } else {
                    Button(action: {
                        processPayment()
                    }) {
                        Text("Proceed with Payment")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(width: 300)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        onCompletion(false)
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .padding()
                            .frame(width: 300)
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.8))
            .cornerRadius(15)
        }
    }
    
    private func processPayment() {
        isProcessing = true
        errorMessage = nil
        
        // Get a payment intent from the backend
        PaymentAPIService.createPaymentIntent(amount: amount, fundraiserId: fundraiserId) { result in
            switch result {
            case .success(let paymentIntentData):
                // Present the payment sheet
                presentPaymentSheet(clientSecret: paymentIntentData.clientSecret)
                
            case .failure(let error):
                isProcessing = false
                errorMessage = "Failed to create payment: \(error.localizedDescription)"
            }
        }
    }
    
    private func presentPaymentSheet(clientSecret: String) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "MasjidFindr"
        configuration.allowsDelayedPaymentMethods = false
        
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
        
        // Use the scene-based window access
        paymentSheet.present(from: UIWindow.keyViewController ?? UIViewController()) { result in
            isProcessing = false
            
            switch result {
            case .completed:
                onCompletion(true)
            case .canceled:
                errorMessage = "Payment was canceled"
            case .failed(let error):
                errorMessage = "Payment failed: \(error.localizedDescription)"
            }
        }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(amount: 99.99, fundraiserId: "123", onCompletion: { _ in })
    }
}
