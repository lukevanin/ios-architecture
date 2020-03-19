//
//  Endpoints.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


protocol Endpoints {
    func creditScore() -> URL
}


struct MockEndpointsImplementation: Endpoints {
    let baseURL: URL
    func creditScore() -> URL {
        return baseURL
            .appendingPathComponent("prod")
            .appendingPathComponent("mockcredit")
            .appendingPathComponent("values", isDirectory: false)
    }
}
