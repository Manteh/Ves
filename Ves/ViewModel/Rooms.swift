//
//  Rooms.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-23.
//

import Foundation
import SwiftUI

struct Room: Identifiable {
    let id = UUID()
    var vesPin: String
    var players: [Player]
}

func getRoom(vesPin: String) -> Room? {
    if vesPin.count == 5 {
        for room in rooms {
            if room.vesPin == vesPin {
                return room
            }
        }
    }
    return nil
}

let rooms = Rooms().rooms

class Rooms {
    
    @State var rooms = [
        Room(vesPin: "CRAZY", players: players)
    ]
    
}

    
