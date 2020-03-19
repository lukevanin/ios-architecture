//
//  Localisations.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import Foundation


enum LocalisationMessage {
    case creditScoreInaccessibleErrorMessage
    case creditScoreUnavailableErrorMessage
    case creditScoreIncompatibleErrorMessage
}


protocol Localisations {
    subscript(message: LocalisationMessage) -> String { get }
}
