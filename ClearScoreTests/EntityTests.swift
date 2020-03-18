//
//  EntityTests.swift
//  ClearScoreTests
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import XCTest
@testable import ClearScore

final class EntityTests: XCTestCase {
    
    func testEquality() {
        let score = 5
        let minScore = 61
        let maxScore = 107
        let a = CreditResponseDTO(
            creditReportInfo: .init(
                score: score,
                minScoreValue: minScore,
                maxScoreValue: maxScore
            )
        )
        let b = CreditResponseDTO(
            creditReportInfo: .init(
                score: score,
                minScoreValue: minScore,
                maxScoreValue: maxScore
            )
        )
        XCTAssertEqual(a, b)
    }
    
    func testInequality() {
        let score = 1
        let minScore = 7
        let maxScore = 13
        let a = CreditResponseDTO(
            creditReportInfo: .init(
                score: score,
                minScoreValue: minScore,
                maxScoreValue: maxScore
            )
        )
        let b = CreditResponseDTO(
            creditReportInfo: .init(
                score: score + 1,
                minScoreValue: minScore,
                maxScoreValue: maxScore
            )
        )
        XCTAssertNotEqual(a, b)
    }

    func testDecodeJSON() throws {
        let json = """
            {
                "creditReportInfo": {
                    "score": 314,
                    "maxScoreValue": 345,
                    "minScoreValue": 178
                }
            }
        """
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder().decode(CreditResponseDTO.self, from: data)
        let expected = CreditResponseDTO(
            creditReportInfo: .init(
                score: 314,
                minScoreValue: 178,
                maxScoreValue: 345
            )
        )
        XCTAssertEqual(result, expected)
    }
}
