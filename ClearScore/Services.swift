//
//  Services.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


// MARK: JSON


enum ServiceError: Error {
    case connection(ConnectionError)
    case content(Error)
}


protocol WebService {
    func get<T>(url: URL, completion: @escaping (Result<T, ServiceError>) -> Void) where T: Decodable
}


final class JSONWebService: WebService {
    struct Config {
        static let `default` = Config(
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 30
        )
        let cachePolicy: NSURLRequest.CachePolicy
        let timeoutInterval: TimeInterval
    }
    private let config: Config
    private let service: HTTPService
    private let decoder: JSONDecoder
    init(config: Config, service: HTTPService, decoder: JSONDecoder) {
        self.config = config
        self.service = service
        self.decoder = decoder
    }
    func get<T>(url: URL, completion: @escaping (Result<T, ServiceError>) -> Void) where T : Decodable {
        let request = URLRequest(
            url: url,
            cachePolicy: config.cachePolicy,
            timeoutInterval: config.timeoutInterval
        )
        service.request(request: request) { [decoder] result in
            switch result {
            case .failure(let error):
                completion(.failure(ServiceError.connection(error)))
                
            case .success(let data):
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                }
                catch {
                    completion(.failure(ServiceError.content(error)))
                }
            }
        }
    }
}


// MARK: - Data


struct HTTPError: Error, Equatable {
    enum Kind: Equatable {
        case notFound
        case internalServerError
        case unknown
    }
    let code: Int
    let kind: Kind
    let localizedDescription: String
}

extension HTTPError {
    init(code: Int) {
        self.code = code
        self.localizedDescription = HTTPURLResponse.localizedString(forStatusCode: code)
        switch code {
        case 400 ..< 499:
            self.kind = .notFound
        case 500 ..< 599:
            self.kind = .internalServerError
        default:
            self.kind = .unknown
        }
    }
}


enum ConnectionError: Error {
    case http(HTTPError)
    case application(Error)
    case undefined
}


protocol HTTPService {
    func request(request: URLRequest, completion: @escaping (Result<Data, ConnectionError>) -> Void)
}


final class ConcreteHTTPService: HTTPService {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    func request(request: URLRequest, completion: @escaping (Result<Data, ConnectionError>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                var reason: ConnectionError
                if let error = error {
                    reason = .application(error)
                }
                else if let response = response as? HTTPURLResponse {
                    reason = .http(HTTPError(code: response.statusCode))
                }
                else {
                    reason = .undefined
                }
                completion(.failure(reason))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
