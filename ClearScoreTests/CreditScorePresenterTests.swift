//
//  CreditScorePresenterTests.swift
//  ClearScoreTests
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import XCTest
@testable import ClearScore


final class CreditScorePresenterTests: XCTestCase {
    
    func testValidScore() {
        let interactor = MockCreditInteractor() {
            $0.onCreditScore?(
                CreditScore(
                    score: 44,
                    minScore: 33,
                    maxScore: 55
                )
            )
        }
        let expectedViewModel = CreditScoreViewModel(
            minScoreValue: 33,
            maxScoreValue: 55,
            scoreValue: 44,
            scoreValueLabel: "44",
            scoreMaxLabel: "55"
        )
        let localisations = MockLocalisations()
        let e = expectation(description: "presenter-viewstate")
        let presenter = CreditScorePresenterImplementation(
            interactor: interactor,
            localisations: localisations,
            wireframe: nil,
            observer: {
                XCTAssertEqual($0, expectedViewModel)
                e.fulfill()
            }
        )
        wait(for: [e], timeout: 1.0)
    }
    
    func testInaccessibleError() {
        let interactor = MockCreditInteractor() {
            $0.onError?(.inaccessible)
        }
        let localisations = MockLocalisations()
        let e = expectation(description: "wireframe-error")
        let wireframe = MockCreditScoreWireframe() {
            XCTAssertEqual($0, localisations[.creditScoreInaccessibleErrorMessage])
            e.fulfill()
        }
        let presenter = CreditScorePresenterImplementation(
            interactor: interactor,
            localisations: localisations,
            wireframe: wireframe,
            observer: nil
        )
        wait(for: [e], timeout: 1.0)
    }
    
    func testUnavailableError() {
        let interactor = MockCreditInteractor() {
            $0.onError?(.unavailable)
        }
        let localisations = MockLocalisations()
        let e = expectation(description: "wireframe-error")
        let wireframe = MockCreditScoreWireframe() {
            XCTAssertEqual($0, localisations[.creditScoreUnavailableErrorMessage])
            e.fulfill()
        }
        let presenter = CreditScorePresenterImplementation(
            interactor: interactor,
            localisations: localisations,
            wireframe: wireframe,
            observer: nil
        )
        wait(for: [e], timeout: 1.0)
    }
    
    func testIncompatibleError() {
        let interactor = MockCreditInteractor() {
            $0.onError?(.incompatible)
        }
        let localisations = MockLocalisations()
        let e = expectation(description: "wireframe-error")
        let wireframe = MockCreditScoreWireframe() {
            XCTAssertEqual($0, localisations[.creditScoreIncompatibleErrorMessage])
            e.fulfill()
        }
        let presenter = CreditScorePresenterImplementation(
            interactor: interactor,
            localisations: localisations,
            wireframe: wireframe,
            observer: nil
        )
        wait(for: [e], timeout: 1.0)
    }
}
