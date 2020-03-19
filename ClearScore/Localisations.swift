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


final class StaticLocalisationsImplementation: Localisations {
    private var localisations = [LocalisationMessage : String]()
    subscript(message: LocalisationMessage) -> String {
        get {
            return localisations[message] ?? String(describing: message)
        }
        set {
            localisations[message] = newValue
        }
    }
}
