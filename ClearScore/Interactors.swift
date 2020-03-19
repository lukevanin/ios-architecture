//
//  Interactors.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


// MARK: - Abstract Interactors


struct CreditScore: Equatable {
    let score: Int
    let minScore: Int
    let maxScore: Int
}

extension CreditScore {
    init(from data: CreditResponseDTO) {
        self.score = data.creditReportInfo.score
        self.minScore = data.creditReportInfo.minScoreValue
        self.maxScore = data.creditReportInfo.maxScoreValue
    }
}


enum CreditScoreError: Error, Equatable {
    // Credit score service is currently inaccessible.
    // e.g. Internnal server error, or server under maintenance.
    case inaccessible
    // Credit score service is currently unavailable.
    // e.g. Internet connectivity issue.
    case unavailable
    // Credit score service is incompatible with this application.
    // e.g. App upgrade required.
    case incompatible
}

extension CreditScoreError {
    init(from error: RepositoryError) {
        guard let serviceError = error.underlyingError as? ServiceError else {
            self = .unavailable
            return
        }
        switch serviceError {
        case .content(_):
            self = .incompatible
        case .connection(.client(_)):
            self = .inaccessible
        case .connection(.server(_)):
            self = .unavailable
        case .connection(.undefined):
            #warning("TODO: Maybe map undefined errors to an explicit state for better reporting")
            self = .inaccessible
        }
    }
}


protocol CreditScoreInteractorOutput {
    typealias OnCreditScore = (CreditScore) -> Void
    typealias OnError = (CreditScoreError) -> Void
    var onCreditScore: OnCreditScore? { get set }
    var onError: OnError? { get set }
}


protocol CreditScoreInteractorInput {
    func getLatestCreditScore()
}


// MARK: - Concrete Credit Score Interactor


final class CreditScoreRepositoryInteractor: CreditScoreInteractorInput, CreditScoreInteractorOutput {
    var onCreditScore: CreditScoreInteractorOutput.OnCreditScore?
    var onError: CreditScoreInteractorOutput.OnError?
    private let repository: CreditRepository
    init(repository: CreditRepository) {
        self.repository = repository
    }
    func getLatestCreditScore() {
        repository.getCreditScore { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                
            case .success(let data):
                self.onCreditScore?(CreditScore(from: data))
                
            case .failure(let error):
                self.onError?(CreditScoreError(from: error))
            }
        }
    }
}
