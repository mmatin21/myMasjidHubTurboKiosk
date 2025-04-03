//
//  PaymentAPIService.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation

struct PaymentIntentResponse: Decodable {
    let clientSecret: String
    let paymentIntentId: String
}

class PaymentAPIService {
    static func createPaymentIntent(amount: Double, fundraiserId: String, completion: @escaping (Result<PaymentIntentResponse, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "amount": amount,
            "fundraiser_id": fundraiserId
        ]
        
        APIService.shared.request(
            endpoint: "\(AppConstants.kioskEndpoint)/payment_intent",
            method: "POST",
            parameters: parameters
        ) { (result: Result<PaymentIntentResponse, APIError>) in
            completion(result)
        }
    }
}
