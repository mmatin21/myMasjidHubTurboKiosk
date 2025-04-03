//
//  AuthService.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation

struct AuthResponse: Decodable {
    let token: String
}

class AuthService {
    static func authenticate(masjidId: String, password: String, completion: @escaping (Result<String, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "masjid_id": masjidId,
            "password": password
        ]
        
        APIService.shared.request(
            endpoint: "\(AppConstants.kioskEndpoint)/auth",
            method: "POST",
            parameters: parameters
        ) { (result: Result<AuthResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
