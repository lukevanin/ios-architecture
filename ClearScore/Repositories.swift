//
//  Repositories.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


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


protocol CreditRepository {
    typealias CreditScoreResult = Result<CreditResponseDTO, RepositoryError>
    typealias CreditScoreCompletion = (CreditScoreResult) -> Void
    func getCreditScore(completion: @escaping CreditScoreCompletion)
}


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
