//
//  APIService.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation

enum APIError: Error {
    case requestFailed(Error)
    case invalidResponse
    case invalidData
    case serverError(Int, String)
    case decodingFailed(Error)
    case unauthorized
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Not authorized"
        case .networkError:
            return "Network connection error"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        // Get base URL from user defaults
        let baseURLString = UserDefaultsManager.getServerURL()
        guard let baseURL = URL(string: baseURLString) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        // Create the URL
        let url = baseURL.appendingPathComponent(endpoint)
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication token if available
        if let token = UserDefaultsManager.getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add parameters
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                completion(.failure(.requestFailed(error)))
                return
            }
        }
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            // Check status code
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidData))
                    }
                    return
                }
                
                // Decode the response
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingFailed(error)))
                    }
                }
                
            case 401:
                DispatchQueue.main.async {
                    completion(.failure(.unauthorized))
                }
                
            default:
                // Server error
                DispatchQueue.main.async {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        completion(.failure(.serverError(httpResponse.statusCode, errorMessage)))
                    } else {
                        completion(.failure(.serverError(httpResponse.statusCode, "Unknown error")))
                    }
                }
            }
        }.resume()
    }
}
