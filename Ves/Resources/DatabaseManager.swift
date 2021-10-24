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
            // Room created
            self.database.child("\(vesPinStringified)").child("roomData").setValue([
                "gameOn": false,
                "playerTurnIndex": 0
            ])
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
        database.child("\(vesPin)/players/\(name)").observeSingleEvent(of: .value, with: { snapshot in
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
            self.database.child("\(vesPin)/players/\(player.name)").setValue([
                "word": player.word,
                "wordTo": player.wordTo,
                "wordFrom": player.wordFrom,
                "leader": false
            ])
            completion()
        })
    }
    
    public func giveLeadership(to name: String, in vesPin: String) {
        self.database.child("\(vesPin)/players/\(name)").child("leader").setValue(true)
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
                self.database.child("\(vesPin)/players/\(player.name)").setValue([])
                print("Removed \(player.name) from \(vesPin)")
                return
            }
        })
    }
    
    public func getPlayers(in vesPin: String, completion: @escaping (([DataSnapshot]) -> Void)) {
        roomExists(with: vesPin, completion: { exists in
            if !exists { return }
                
            self.database.child("\(vesPin)/players").observeSingleEvent(of: .value) { snapshot in
                var players: [DataSnapshot] = []
                for player in snapshot.children.allObjects as! [DataSnapshot] {
                    players.append(player)
                }
                completion(players)
            }
        })
    }
    
    public func onPlayerAdd(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child("\(vesPin)/players").observe(.childAdded, with: { snapshot in
            completion(snapshot)
        })
    }
    
    public func onPlayerRemove(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child("\(vesPin)/players").observe(.childRemoved, with: { snapshot in
            completion(snapshot)
        })
    }
    
    public func onPlayerChange(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child("\(vesPin)/players").observe(.childChanged, with: { snapshot in
            completion(snapshot)
        })
    }
    
    public func isGameOn(in vesPin: String, completion: @escaping((Bool) -> Void)) {
        self.database.child(vesPin).child("roomData").observeSingleEvent(of: .value) { snapshot in
            guard let isGameOn = snapshot.childSnapshot(forPath: "gameOn").value as? Bool else {
                print("!err! \(snapshot.children.allObjects)")
                return
            }
            
            print("isGameOn: \(isGameOn)")
            completion(isGameOn)
        }
    }
    
    public func startGame(in vesPin: String) {
        self.database.child("\(vesPin)/roomData/").updateChildValues(["gameOn": true])
    }
    
    public func onRoomChange(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child("\(vesPin)/roomData").observe(.childChanged, with: { snapshot in
            completion(snapshot)
        })
    }
}

// MARK: - Word Managment
extension DatabaseManager {
    public func giveWord(word: String, to name: String, in vesPin: String) {
        DatabaseManager.shared.playerExists(in: vesPin, with: name, completion: { exists in
            guard exists else {
                print("Player doesn't exist")
                return
            }
            
            self.database.child("\(vesPin)/players/\(name)").updateChildValues(["word": word])
        })
    }
    
    public func randomWordsAll(in vesPin: String, completion: @escaping () -> Void) {
        self.database.child("\(vesPin)/players").observeSingleEvent(of: .value, with: { snapshot in
            snapshot.children.forEach { p in
                let name = (p as! DataSnapshot).key
                self.giveWord(word: WordManager.shared.randomWord()!, to: name, in: vesPin)
            }
            completion()
        })
    }
}

//MARK: - Game Management
extension DatabaseManager {
    public func nextPlayerTurn(in vesPin: String) {
        self.getPlayers(in: vesPin, completion: { players in
            self.database.child("\(vesPin)/roomData").observeSingleEvent(of: .value, with: { snapshot in
                guard let currentPlayerIndex = snapshot.childSnapshot(forPath: "playerTurnIndex").value as? Int else {
                    print("!err! \(snapshot.children.allObjects)")
                    return
                }
                
                if currentPlayerIndex + 1 < players.count {
                    self.database.child("\(vesPin)/roomData").updateChildValues(["playerTurnIndex": currentPlayerIndex + 1])
                } else {
                    self.database.child("\(vesPin)/roomData").updateChildValues(["playerTurnIndex": 0])
                }
            })
        })
    }
}

