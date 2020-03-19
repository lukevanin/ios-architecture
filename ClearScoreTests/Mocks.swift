//
//  Mocks.swift
//  ClearScoreTests
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation
@testable import ClearScore


final class MockCreditRepository: CreditRepository {
    typealias Handler = () -> CreditRepository.CreditScoreResult
    var handler: Handler
    var queue: DispatchQueue
    init(queue: DispatchQueue? = nil, handler: Handler? = nil) {
        self.handler = handler ?? {
            return .failure(.init(kind: .unknown, underlyingError: nil))
        }
        self.queue = queue ?? DispatchQueue(label: "credit-repository")
    }
    func getCreditScore(completion: @escaping CreditRepository.CreditScoreCompletion) {
        queue.async { [handler] in
            completion(handler())
        }
    }
}


class MockHTTPService: HTTPService {
    typealias Handler = (URLRequest) -> Result<Data, ConnectionError>
    var handler: Handler
    private let queue: DispatchQueue
    init(queue: DispatchQueue? = nil, handler: Handler? = nil) {
        self.handler = handler ?? { (request: URLRequest) -> Result<Data, ConnectionError> in
            return .failure(.undefined)
        }
        self.queue = queue ?? DispatchQueue(label: "mock-http-service")
    }
    func request(request: URLRequest, completion: @escaping (Result<Data, ConnectionError>) -> Void) {
        queue.async { [handler] in
            completion(handler(request))
        }
    }
}
