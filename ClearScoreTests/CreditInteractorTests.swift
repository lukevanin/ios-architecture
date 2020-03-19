//
//  CreditInteractorTests.swift
//  ClearScoreTests
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import XCTest
@testable import ClearScore


final class CreditInteractorTests: XCTestCase {
    
    enum TestError: Error {
        case zombiesAteMyHomework
    }
    
    func testValidData() {
        let expected = CreditScore(
            score: 17,
            minScore: 7,
            maxScore: 13
        )
        let repository = MockCreditRepository() {
            return .success(
                .init(
                    creditReportInfo: .init(
                        score: expected.score,
                        minScoreValue: expected.minScore,
                        maxScoreValue: expected.maxScore
                    )
                )
            )
        }
        let interactor = CreditScoreRepositoryInteractor(
            repository: repository
        )
        let e = expectation(description: "credit-score")
        interactor.onCreditScore = {
            XCTAssertEqual($0, expected)
            e.fulfill()
        }
        interactor.getLatestCreditScore()
        wait(for: [e], timeout: 1.0)
    }
    
    func testIncompatibleError() {
        let repository = MockCreditRepository() {
            return .failure(
                .init(
                    from: .content(TestError.zombiesAteMyHomework)
                )
            )
        }
        let interactor = CreditScoreRepositoryInteractor(
            repository: repository
        )
        let e = expectation(description: "credit-score")
        interactor.onError = {
            XCTAssertEqual($0, CreditScoreError.incompatible)
            e.fulfill()
        }
        interactor.getLatestCreditScore()
        wait(for: [e], timeout: 1.0)
    }
    
    func testUnavailableError() {
        let repository = MockCreditRepository() {
            return .failure(
                .init(
                    from: .connection(.server(HTTPError(code: 404)))
                )
            )
        }
        let interactor = CreditScoreRepositoryInteractor(
            repository: repository
        )
        let e = expectation(description: "credit-score")
        interactor.onError = {
            XCTAssertEqual($0, CreditScoreError.unavailable)
            e.fulfill()
        }
        interactor.getLatestCreditScore()
        wait(for: [e], timeout: 1.0)
    }
    
    func testInaccessibleError() {
        let repository = MockCreditRepository() {
            return .failure(
                .init(
                    from: .connection(.client(TestError.zombiesAteMyHomework))
                )
            )
        }
        let interactor = CreditScoreRepositoryInteractor(
            repository: repository
        )
        let e = expectation(description: "credit-score")
        interactor.onError = {1
            XCTAssertEqual($0, CreditScoreError.inaccessible)
            e.fulfill()
        }
        interactor.getLatestCreditScore()
        wait(for: [e], timeout: 1.0)

    }
}
