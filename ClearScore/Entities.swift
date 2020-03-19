//
//  Entities.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


///
/// Application model
///
struct AppModel: Equatable {
    struct CreditInfo: Equatable {
        var score: Int
        var minScoreValue: Int
        var maxScoreValue: Int
    }
    var creditInfo: CreditInfo?
}
