//
//  CardPaymentHandler.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation
import Stripe
import UIKit
import StripePaymentSheet

class CardPaymentHandler: ObservableObject {
    @Published var isProcessing = false
    @Published var paymentResult: PaymentResult?
    
    enum PaymentResult {
        case success(String)
        case failure(Error)
    }
    
    func processPayment(clientSecret: String, completion: @escaping (Result<String, Error>) -> Void) {
        isProcessing = true
        
        // Create a payment sheet configuration
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "MasjidFindr"
        configuration.allowsDelayedPaymentMethods = false
        
        // Create the payment sheet
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
        
        // Present the payment sheet
        paymentSheet.present(from: UIApplication.shared.windows.first?.rootViewController ?? UIViewController()) { result in
            self.isProcessing = false
            
            switch result {
            case .completed:
                // Extract the payment intent ID from the client secret
                let components = clientSecret.components(separatedBy: "_secret_")
                let paymentIntentId = components.first ?? "unknown"
                
                self.paymentResult = .success(paymentIntentId)
                completion(.success(paymentIntentId))
                
            case .canceled:
                let error = NSError(domain: "com.masjidkiosk", code: 1, userInfo: [NSLocalizedDescriptionKey: "Payment canceled"])
                self.paymentResult = .failure(error)
                completion(.failure(error))
                
            case .failed(let error):
                self.paymentResult = .failure(error)
                completion(.failure(error))
            }
        }
    }
}
