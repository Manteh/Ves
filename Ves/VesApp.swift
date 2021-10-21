//
//  VesApp.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import SwiftUI
import UIKit
import Firebase

@main
struct VesApp: App {
    
    init() {
        FirebaseApp.configure()
//        let player = Player(name: "Steve", word: "Apple", wordTo: "", wordFrom: "")
//        let player2 = Player(name: "Elon", word: "SpaceX", wordTo: "", wordFrom: "")
//
//        DatabaseManager.shared.createNewRoom(with: player, completion: { pin in
//            DatabaseManager.shared.addToRoom(with: player2, to: pin, completion: {})
//        })
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
