//
//  Array+Only.swift
//  SetGame
//
//  Created by Maida on 12/17/20.
//

import Foundation
extension Array {
    var only: Element? {
        count == 1 ? first: nil
    }
}
