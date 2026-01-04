//
//  NetworkService.swift
//  nejskutecnejsiprojekt
//
//  Network layer with async/await support
//

import Foundation

/// Protocol for network operations - enables dependency injection and testing
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from endpoint: String, type: T.Type) async throws -> T
}

/// Errors that can occur during network operations
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .noConnection:
            return "No internet connection"
        }
    }
}

/// Main network service for API calls
final class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    
    private let baseURL = "https://jsonplaceholder.typicode.com"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Fetches and decodes data from the API
    /// - Parameters:
    ///   - endpoint: The API endpoint (e.g., "posts", "users/1")
    ///   - type: The type to decode the response into
    /// - Returns: Decoded object of type T
    func fetch<T: Decodable>(from endpoint: String, type: T.Type) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

/// Mock network service for testing
final class MockNetworkService: NetworkServiceProtocol {
    var mockData: Any?
    var shouldFail = false
    var error: Error = NetworkError.noConnection
    
    func fetch<T: Decodable>(from endpoint: String, type: T.Type) async throws -> T {
        if shouldFail {
            throw error
        }
        
        guard let data = mockData as? T else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
}

