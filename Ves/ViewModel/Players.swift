//
//  Players.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-26.
//

import Foundation
import SwiftUI

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var word: String?
    var wordTo: String?
    var wordFrom: String?
}

var players = [
    Player(name: "Elon", word: nil, wordTo: nil, wordFrom: nil),
    Player(name: "Steve", word: nil, wordTo: nil, wordFrom: nil),
    Player(name: "Thomas", word: nil, wordTo: nil, wordFrom: nil)
]

