//
//  PaymentResultView.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI

struct PaymentResultView: View {
    let isSuccess: Bool
    let amount: Double
    let paymentId: String?
    let errorMessage: String?
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if isSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    
                    Text("Payment Successful!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Amount: \(CurrencyFormatter.format(amount))")
                        .font(.title2)
                    
                    if let paymentId = paymentId {
                        Text("Payment ID: \(paymentId)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                    
                    Text("Payment Failed")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                Button(action: onDismiss) {
                    Text(isSuccess ? "Continue" : "Try Again")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 200)
                        .background(isSuccess ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}

struct PaymentResultView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentResultView(
            isSuccess: true,
            amount: 99.99,
            paymentId: "pi_123456789",
            errorMessage: nil,
            onDismiss: {}
        )
    }
}
