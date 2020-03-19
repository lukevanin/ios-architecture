//
//  Modules.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import UIKit


final class StaticLocalisationsBuilder {
    func build() -> Localisations {
        #warning("TODO: Load localisations from standard localisation files.")
        let output = StaticLocalisationsImplementation()
        output[.creditScoreInaccessibleErrorMessage] = "Your credit score is not accessible at this time. Please ensure your internet connection is working, then try again."
        output[.creditScoreUnavailableErrorMessage] = "The credit score service is currently unavailable. Please try again, or reach out to our support team for assistance."
        output[.creditScoreIncompatibleErrorMessage] = "It appears this app is no longer compatible with the credit score service. Please upgrade to the latest version of the app, available on the App Store."
        return output
    }
}


final class CreditScoreModuleBuilder {
    private let endpoints: Endpoints
    private let localisations: Localisations
    private let session: URLSession
    init(endpoints: Endpoints, localisations: Localisations, session: URLSession) {
        self.endpoints = endpoints
        self.localisations = localisations
        self.session = session
    }
    func build() -> UIViewController {
        let httpService = ConcreteHTTPService(
            session: session
        )
        let repository = WebCreditRepository(
            baseURL: endpoints.creditScore(),
            service: httpService
        )
        let interactor = CreditScoreRepositoryInteractor(
            repository: repository
        )
        #warning("TODO: Implement wireframe to show error")
        let presenter = CreditScorePresenterImplementation(
            interactor: interactor,
            localisations: localisations,
            wireframe: nil,
            observer: nil
        )
        let viewController = CreditScoreViewController(
            presenter: presenter
        )
        return viewController
    }
}
