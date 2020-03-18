//
//  CreditRepositoryTests.swift
//  ClearScoreTests
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import XCTest
@testable import ClearScore

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
    
    func testGetCreditResponseError() {
        let httpError = HTTPError(code: 400)
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
                if let underlyingError = error.underlyingError as? ConnectionError {
                    switch underlyingError {
                    
                    case .http(let error):
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
    
    private func makeCreditRepository(httpService: HTTPService) -> WebCreditRepository {
        return WebCreditRepository(
            baseURL: URL(string: "http://example.org/")!,
            config: JSONWebService.Config(
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 5
            ),
            service: httpService
        )
    }
}
