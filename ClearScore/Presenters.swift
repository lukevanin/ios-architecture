//
//  Presenters.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


// MARK: - CreditScorePresenter Implementation


protocol CreditScoreWireframe {
    func showError(message: String)
}


struct CreditScoreViewModel: Equatable {
    let minScoreValue: Int
    let maxScoreValue: Int
    let scoreValue: Int
    let scoreValueLabel: String
    let scoreMaxLabel: String
}


final class CreditScorePresenterImplementation: CreditScorePresenter {
    
    typealias Observer = (CreditScoreViewModel) -> Void
    
    var observer: Observer?
    
    typealias Interactor = CreditScoreInteractorInput & CreditScoreInteractorOutput
    private var interactor: Interactor
    private let wireframe: CreditScoreWireframe?
    private let localisations: Localisations
    private let numberFormatter: NumberFormatter
    
    init(interactor: Interactor, localisations: Localisations, wireframe: CreditScoreWireframe?, observer: Observer?) {
        self.observer = observer
        self.interactor = interactor
        self.wireframe = wireframe
        self.localisations = localisations
        self.numberFormatter = NumberFormatter()
        self.interactor.onCreditScore = { [weak self] score in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.present(score: score)
            }
        }
        self.interactor.onError = { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.present(error: error)
            }
        }
        refreshCreditScore()
    }
    
    private func present(score: CreditScore) {
        observer?(makeViewModel(from: score))
    }
    
    private func present(error: CreditScoreError) {
        wireframe?.showError(message: makeError(from: error))
    }
    
    private func makeViewModel(from score: CreditScore) -> CreditScoreViewModel {
        return CreditScoreViewModel(
            minScoreValue: score.minScore,
            maxScoreValue: score.maxScore,
            scoreValue: score.score,
            scoreValueLabel: numberFormatter.string(from: NSNumber(value: score.score))!,
            scoreMaxLabel: numberFormatter.string(from: NSNumber(value: score.maxScore))!
        )
    }
    
    private func makeError(from error: CreditScoreError) -> String {
        let message: String
        switch error {
        case .inaccessible:
            message = localisations[.creditScoreInaccessibleErrorMessage]
        case .unavailable:
            message = localisations[.creditScoreUnavailableErrorMessage]
        case .incompatible:
            message = localisations[.creditScoreIncompatibleErrorMessage]
        }
        return message
    }

    func refreshCreditScore() {
        interactor.getLatestCreditScore()
    }
}
