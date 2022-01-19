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
                "showWordPick": false,
                "showWordReveal": false,
                "latestReveal": [""]
            ])
            self.addToRoom(with: player, to: vesPinStringified, completion: {
                self.giveLeadership(to: player.name, in: vesPinStringified)
                completion(vesPinStringified)
            })
        })
    }
    
    public func deleteRoom(with vesPin: String) {
        self.roomExists(with: vesPin, completion: { exists in
            if exists {
                DispatchQueue.main.async {
                    self.database.child("\(vesPin)").removeValue()
                }
            }
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
                "leader": false,
                "turns": 0,
                "color": ["orange"].randomElement()!
            ])
            completion()
        })
    }
    
    public func addToFinishedPlayers(with player: DataSnapshot, to vesPin: String, completion: @escaping ((DataSnapshot) -> Void)) {
        print("Adding \(player.key) to \(vesPin) finished")
        self.database.child("\(vesPin)/roomData/finishedPlayers/\(player.key)").setValue([
            "word": player.childSnapshot(forPath: "word").value,
            "wordTo": player.childSnapshot(forPath: "wordTo").value,
            "wordFrom": player.childSnapshot(forPath: "wordFrom").value,
            "turns": player.childSnapshot(forPath: "turns").value,
        ])
        
        self.database.child("\(vesPin)/roomData/latestReveal").setValue([
            "name": player.key,
            "word": player.childSnapshot(forPath: "word").value,
            "wordTo": player.childSnapshot(forPath: "wordTo").value,
            "wordFrom": player.childSnapshot(forPath: "wordFrom").value,
            "turns": player.childSnapshot(forPath: "turns").value,
        ])
        
        self.removeFromRoom(with: player.key, from: vesPin)
        completion(player)
    }
    
    public func getLatestReveal(in vesPin: String, completion: @escaping ((DataSnapshot) -> Void)) {
        roomExists(with: vesPin, completion: { exists in
            if !exists { return }
                
            self.database.child("\(vesPin)/roomData/latestReveal").observeSingleEvent(of: .value) { snapshot in
                var players: [DataSnapshot] = []
                for player in snapshot.children.allObjects as! [DataSnapshot] {
                    players.append(player)
                }
                completion(players[0])
            }
        })
    }
    
    public func getFinishedPlayers(in vesPin: String, completion: @escaping (([DataSnapshot]) -> Void)) {
        roomExists(with: vesPin, completion: { exists in
            if !exists { return }
                
            self.database.child("\(vesPin)/roomData/finishedPlayers").observeSingleEvent(of: .value) { snapshot in
                var players: [DataSnapshot] = []
                for player in snapshot.children.allObjects as! [DataSnapshot] {
                    players.append(player)
                }
                completion(players.sorted(by: { a, b in
                    let turnA = a.childSnapshot(forPath: "turns").value as! Int
                    let turnB = b.childSnapshot(forPath: "turns").value as! Int
                    return turnA < turnB
                }))
            }
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
    
    public func removeFromRoom(with name: String, from vesPin: String) {
        print("RemoveFromRoom:")
        playerExists(in: vesPin, with: name, completion: { exists in
            print("RemoveFromRoom: Checking if player exists")
            guard !exists else {
                print("RemoveFromRoom: Performing player removal")
                DispatchQueue.main.async {
                    self.database.child("\(vesPin)/players/\(name)").setValue([])
                    print("Removed \(name) from \(vesPin)")
                }
                
                print("RemoveFromRoom: Checking if room is empty")
                DispatchQueue.main.async {
                    self.getPlayers(in: vesPin, completion: { players in
                        if players.count == 0 {
                            self.getFinishedPlayers(in: vesPin) { finishedPlayers in
                                if finishedPlayers.count == 0 {
                                    print("RemoveFromRoom: Deleting room")
                                    self.deleteRoom(with: vesPin)
                                }
                            }
                        }
                    })
                }
                
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
    
    public func waitingViewUpdate(on vesPin: String, players: [DataSnapshot]) {
        var suggestingPlayers = players
        DatabaseManager.shared.getPlayers(in: vesPin) { dbPlayers in
            suggestingPlayers.removeAll()
            for p in dbPlayers {
                if p.childSnapshot(forPath: "word").value as! String == "" {
                    let wordGiver = dbPlayers.filter { $0.key == p.childSnapshot(forPath: "wordFrom").value as! String}
                    if suggestingPlayers.firstIndex(of: wordGiver[0]) == nil {
                        suggestingPlayers.append(wordGiver[0])
                    }
                }
            }
        }
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
    
    public func startWordPicking(in vesPin: String) {
        self.database.child("\(vesPin)/roomData/").updateChildValues(["showWordPick": true])
    }
    
    public func endWordPicking(in vesPin: String) {
        self.database.child("\(vesPin)/roomData/").updateChildValues(["showWordPick": false])
    }
    
    public func onRoomChange(on vesPin: String, completion: @escaping (DataSnapshot) -> Void) {
        self.database.child("\(vesPin)/roomData").observe(.childChanged, with: { snapshot in
            completion(snapshot)
        })
    }
    
    public func performWordReveal(in vesPin: String) {
        self.database.child("\(vesPin)/roomData/").updateChildValues(["showWordReveal": true])
        self.database.child("\(vesPin)/roomData/").updateChildValues(["showWordReveal": false])
    }
    
}

// MARK: - Word Managment
extension DatabaseManager {
    public func giveWord(word: String, to: String, in vesPin: String, completion: @escaping () -> Void) {
        DatabaseManager.shared.playerExists(in: vesPin, with: to, completion: { exists in
            guard exists else {
                print("Giving word to player: Player doesn't exist")
                return
            }
            
            self.database.child("\(vesPin)/players/\(to)").updateChildValues(["word": word])
            print("Giving word to player: Added word |\(word)| to |\(to)|")
            completion()
        })
    }
    
    public func linkPlayers(giver: String, receiver: String, in vesPin: String) {
        DatabaseManager.shared.playerExists(in: vesPin, with: receiver, completion: { exists in
            guard exists else {
                print("Receiver doesn't exist")
                return
            }
            
            self.database.child("\(vesPin)/players/\(receiver)").updateChildValues(["wordFrom": giver])
            self.database.child("\(vesPin)/players/\(giver)").updateChildValues(["wordTo": receiver])
        })
    }
    
    public func getNoWordPlayers(in vesPin: String, completion: @escaping ([DataSnapshot]) -> Void) {
        self.getPlayers(in: vesPin) { dbPlayers in
            completion(dbPlayers.filter { $0.childSnapshot(forPath: "word").value as! String == "" })
        }
    }
    
}

//MARK: - Game Management
extension DatabaseManager {
    
    public func turnMadeBy(name: String, in vesPin: String, completion: @escaping ([DataSnapshot]) -> Void) {
        self.database.updateChildValues(["\(vesPin)/players/\(name)/turns": ServerValue.increment(1)]) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Turns addition failed: \(error).")
            } else {
                self.nextTurn(in: vesPin, completion: { updatedPlayers in
                    completion(updatedPlayers)
                })
            }
        }
    }
    
    public func nextRoomTurn(in vesPin: String, completion: @escaping (Int) -> Void) {
        self.database.updateChildValues(["\(vesPin)/roomData/roomTurns": ServerValue.increment(1)])
    }
    
    public func getTurns(name: String, in vesPin: String, completion: @escaping (Int) -> Void) {
        self.database.child("\(vesPin)/players/\(name)").observeSingleEvent(of: .value, with: { snapshot in
            guard let turns = snapshot.childSnapshot(forPath: "turns").value as? Int else {
                print("!err! \(snapshot.children.allObjects)")
                return
            }
            completion(turns)
        })
    }
    
    public func getRoomTurns(in vesPin: String, completion: @escaping (Int) -> Void) {
        self.database.child("\(vesPin)/roomData/").observeSingleEvent(of: .value, with: { snapshot in
            guard let turns = snapshot.childSnapshot(forPath: "roomTurns").value as? Int else {
                print("!err! \(snapshot.children.allObjects)")
                return
            }
            completion(turns)
        })
    }
    
    public func nextTurn(in vesPin: String, completion: @escaping ([DataSnapshot]) -> Void) {
        self.getPlayers(in: vesPin, completion: { dbPlayers in
            var sortedPlayers = dbPlayers
            
            sortedPlayers.sort {
                ($0.childSnapshot(forPath: "turns").value as! Int) < ($1.childSnapshot(forPath: "turns").value as! Int)
            }
            completion(sortedPlayers)
        })
    }
    
}

