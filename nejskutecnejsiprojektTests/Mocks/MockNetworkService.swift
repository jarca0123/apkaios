//
//  MockNetworkService.swift
//  nejskutecnejsiprojektTests
//
//  Mock network service for testing
//

import Foundation
@testable import nejskutecnejsiprojekt

/// Mock network service for testing - only used in test target
actor MockNetworkService: NetworkServiceProtocol {
    var mockData: Any?
    var shouldFail = false
    var error: Error = NetworkError.noConnection
    
    func setMockData(_ data: Any?) {
        mockData = data
    }
    
    func setShouldFail(_ fail: Bool, error: Error = NetworkError.noConnection) {
        shouldFail = fail
        self.error = error
    }
    
    nonisolated func fetch<T: Decodable>(from endpoint: String, type: T.Type) async throws -> T {
        let shouldFail = await self.shouldFail
        let error = await self.error
        let mockData = await self.mockData
        
        if shouldFail {
            throw error
        }
        
        guard let data = mockData as? T else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
}

