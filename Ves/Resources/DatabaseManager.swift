//
//  DatabaseManager.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-07.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {

    let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

// MARK: - Room Managment

extension DatabaseManager {
    
    /// Creates new game room
    public func createNewRoom(with player: Player, completion: @escaping ((String) -> Void)) {
        var vesPin = ["", "", "", "", ""]
        
        // Generate a random vesPin (length of 5)
        for (i, _) in vesPin.enumerated() {
            vesPin[i] = chars[Int.random(in: 0..<chars.count)]
        }
        
        let vesPinStringified = vesPin.joined(separator: "").uppercased()
        print("Pin is \(vesPinStringified)")
        
        roomExists(with: vesPinStringified, completion: { exists in
            guard !exists else {
                self.createNewRoom(with: player, completion: {_ in })
                return
            }
            self.addToRoom(with: player, to: vesPinStringified, completion: {
                self.giveLeadership(to: player.name, in: vesPinStringified)
                completion(vesPinStringified)
            })
        })
    }
    
    /// Checks if room with vesPin exists
    public func roomExists(with vesPin: String, completion: @escaping ((Bool) -> Void)) {
        database.child("\(vesPin)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    /// Checks if player with a name already exists in the game room
    public func playerExists(in vesPin: String, with name: String, completion: @escaping ((Bool) -> Void)) {
        database.child("\(vesPin)/\(name)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    /// Adds player to a game room
    public func addToRoom(with player: Player, to vesPin: String, completion: @escaping (() -> Void)) {
        if vesPin.count < 5 { return }
        
        playerExists(in: vesPin, with: player.name, completion: { exists in
            guard !exists else {
                // Player with that name already exists in the room
                print("Player with that name already exists in the room || \(player.name) in \(vesPin)")
                return
            }
            
            print("Adding \(player.name) to \(vesPin)")
            self.database.child("\(vesPin)/\(player.name)").setValue([
                "word": player.word,
                "wordTo": player.wordTo,
                "wordFrom": player.wordFrom,
                "leader": false
            ])
            completion()
        })
    }
    
    public func giveLeadership(to name: String, in vesPin: String) {
        self.database.child("\(vesPin)/\(name)").child("leader").setValue(true)
    }
    
    public func isLeader(with name: String, in vesPin: String, completion: @escaping((Bool) -> Void)){
        self.database.child(vesPin).child(name).observeSingleEvent(of: .value) { snapshot in
            guard let leadership = snapshot.childSnapshot(forPath: "leader").value as? Bool else {
                print("!err! \(snapshot.children.allObjects)")
                return
            }
            
            print("leader: \(leadership)")
            completion(leadership)
        }
    }
    
    public func removeFromRoom(with player: Player, from vesPin: String) {
        playerExists(in: vesPin, with: player.name, completion: { exists in
            guard !exists else {
                self.database.child("\(vesPin)/\(player.name)").setValue([])
                print("Removed \(player.name) from \(vesPin)")
                return
            }
        })
    }
    
    public func getPlayers(in vesPin: String, completion: @escaping (([DataSnapshot]) -> Void)) {
        roomExists(with: vesPin, completion: { exists in
            if !exists { return }
                
            self.database.child(vesPin).observeSingleEvent(of: .value) { snapshot in
                var players: [DataSnapshot] = []
                for player in snapshot.children.allObjects as! [DataSnapshot] {
                    players.append(player)
                }
                completion(players)
            }
        })
    }
    
    public func onPlayerAdd(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child(vesPin).observe(.childAdded, with: { snapshot in
            completion(snapshot)
        })
    }
    
    public func onPlayerRemove(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child(vesPin).observe(.childRemoved, with: { snapshot in
            completion(snapshot)
        })
    }
    
    public func onPlayerChange(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child(vesPin).observe(.childChanged, with: { snapshot in
            completion(snapshot)
        })
    }
}

