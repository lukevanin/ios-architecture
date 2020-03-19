//
//  Repositories.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


// MARK: Abstract Repository


struct RepositoryError: Error {
    enum Kind {
        case unavailable
        case incompatible
        case unknown
    }
    let kind: Kind
    let underlyingError: Error?
}

extension RepositoryError {
    init(from serviceError: ServiceError) {
        switch serviceError {

        case .content(_):
            self.kind = .incompatible

        case .connection(_):
            self.kind = .unavailable
        }
        self.underlyingError = serviceError
    }
}


// MARK: - Abstract Credit Repository


struct CreditResponseDTO: Equatable, Decodable {
    struct CreditReportInfo: Equatable, Decodable {
        let score: Int
        let minScoreValue: Int
        let maxScoreValue: Int
    }
    let creditReportInfo: CreditReportInfo
}


protocol CreditRepository {
    typealias CreditScoreResult = Result<CreditResponseDTO, RepositoryError>
    typealias CreditScoreCompletion = (CreditScoreResult) -> Void
    func getCreditScore(completion: @escaping CreditScoreCompletion)
}


// MARK: - Credit Repository Implementation


final class WebCreditRepository: CreditRepository {
    private let baseURL: URL
    private let config: JSONWebService.Config
    private let service: JSONWebService
    init(baseURL: URL, config: JSONWebService.Config = .default, service: HTTPService) {
        self.baseURL = baseURL
        self.config = config
        self.service = JSONWebService(
            config: config,
            service: service,
            decoder: JSONDecoder()
        )
    }

    /*
    Sample data, included here to document the capabilities of the API. Only
    some of this data is used in the sample application, which is reflected by
    the model.

    https://5lfoiyb0b3.execute-api.us-west-2.amazonaws.com/prod/mockcredit/values

    {
        "accountIDVStatus": "PASS",
        "creditReportInfo": {
            "score": 514,
            "scoreBand": 4,
            "clientRef": "CS-SED-655426-708782",
            "status": "MATCH",
            "maxScoreValue": 700,
            "minScoreValue": 0,
            "monthsSinceLastDefaulted": -1,
            "hasEverDefaulted": false,
            "monthsSinceLastDelinquent": 1,
            "hasEverBeenDelinquent": true,
            "percentageCreditUsed": 44,
            "percentageCreditUsedDirectionFlag": 1,
            "changedScore": 0,
            "currentShortTermDebt": 13758,
            "currentShortTermNonPromotionalDebt": 13758,
            "currentShortTermCreditLimit": 30600,
            "currentShortTermCreditUtilisation": 44,
            "changeInShortTermDebt": 549,
            "currentLongTermDebt": 24682,
            "currentLongTermNonPromotionalDebt": 24682,
            "currentLongTermCreditLimit": null,
            "currentLongTermCreditUtilisation": null,
            "changeInLongTermDebt": -327,
            "numPositiveScoreFactors": 9,
            "numNegativeScoreFactors": 0,
            "equifaxScoreBand": 4,
            "equifaxScoreBandDescription": "Excellent",
            "daysUntilNextReport": 9
        },
        "dashboardStatus": "PASS",
        "personaType": "INEXPERIENCED",
        "coachingSummary": {
            "activeTodo": false,
            "activeChat": true,
            "numberOfTodoItems": 0,
            "numberOfCompletedTodoItems": 0,
            "selected": true
        },
        "augmentedCreditScore": null
    }
    */
    func getCreditScore(completion: @escaping CreditRepository.CreditScoreCompletion) {
        service.get(url: baseURL) { (result: Result<CreditResponseDTO, ServiceError>) -> Void in
            switch result {
            
            case .failure(let error):
                completion(.failure(RepositoryError(from: error)))
                
            case .success(let response):
                completion(.success(response))
            }
        }
    }
}
