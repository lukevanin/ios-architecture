//
//  CreditRepositoryTests.swift
//  ClearScoreTests
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import XCTest
@testable import ClearScore

private enum TestError: Error, Equatable {
    case zombies
}

private func makeTestData(from entity: CreditResponseDTO) -> Data {
    let json = """
        {
            "creditReportInfo": {
                "score": \(entity.creditReportInfo.score),
                "maxScoreValue": \(entity.creditReportInfo.maxScoreValue),
                "minScoreValue": \(entity.creditReportInfo.minScoreValue)
            }
        }
    """
    return json.data(using: .utf8)!
}


final class CreditRepositoryTests: XCTestCase {
    
    func testGetCreditResponse() {
        let subject = CreditResponseDTO(
            creditReportInfo: .init(
                score: 3,
                minScoreValue: 4,
                maxScoreValue: 5
            )
        )
        let data = makeTestData(from: subject)
        let httpService = MockHTTPService() { request in
            return .success(data)
        }
        let repository = makeCreditRepository(
            httpService: httpService
        )
        let e = expectation(description: "web-service-response")
        repository.getCreditScore { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, subject)
            
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
    }
    
    func testGetCreditResponseConnectionHTTPError() {
        let httpError = HTTPError(code: 404)
        let httpService = MockHTTPService() { request in
            return .failure(.http(httpError))
        }
        let repository = makeCreditRepository(
            httpService: httpService
        )
        let e = expectation(description: "web-service-response")
        repository.getCreditScore { result in
            switch result {
                
            case .success(_):
                XCTFail("Unexpected success response")

            case .failure(let error):
                XCTAssertEqual(error.kind, .unavailable)
                if let underlyingError = error.underlyingError as? ServiceError {
                    switch underlyingError {
                    
                    case .connection(.http(let error)):
                        XCTAssertEqual(error, httpError)
                        
                    default:
                        XCTFail("Expected HTTP connection error")
                    }
                }
                else {
                    XCTFail("Expected underlying ServiceError")
                }
            }
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
    }
    
    func testGetCreditResponseConnectionApplicationError() {
        let httpService = MockHTTPService() { request in
            return .failure(.application(TestError.zombies))
        }
        let repository = makeCreditRepository(
            httpService: httpService
        )
        let e = expectation(description: "web-service-response")
        repository.getCreditScore { result in
            switch result {
                
            case .success(_):
                XCTFail("Unexpected success response")
                
            case .failure(let error):
                XCTAssertEqual(error.kind, .unavailable)
                if let underlyingError = error.underlyingError as? ServiceError {
                    switch underlyingError {
                        
                    case .connection(.application(let error as TestError)):
                        XCTAssertEqual(error, TestError.zombies)
                        
                    default:
                        XCTFail("Expected application connection error")
                    }
                }
                else {
                    XCTFail("Expected underlying ServiceError")
                }
            }
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
    }
    
    func testGetCreditResponseContentError() {
        let httpService = MockHTTPService() { request in
            let data = "0xBAADF00D".data(using: .utf8)!
            return .success(data)
        }
        let repository = makeCreditRepository(
            httpService: httpService
        )
        let e = expectation(description: "web-service-response")
        repository.getCreditScore { result in
            switch result {
                
            case .success(_):
                XCTFail("Unexpected success response")
                
            case .failure(let error):
                XCTAssertEqual(error.kind, .incompatible)
                if let underlyingError = error.underlyingError as? ServiceError {
                    switch underlyingError {
                        
                    case .content(_):
                        break
                        
                    default:
                        XCTFail("Expected application content error")
                    }
                }
                else {
                    XCTFail("Expected underlying ServiceError")
                }
            }
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
    }
    
    private func makeCreditRepository(httpService: HTTPService) -> WebCreditRepository {
        return WebCreditRepository(
            baseURL: URL(string: "http://example.org/")!,
            service: httpService
        )
    }
}
