//
//  RoomView.swift
//  Ves

//  Created by Mantas Simanauskas on 2021-09-23.
//

import SwiftUI
import FirebaseDatabase

struct RoomView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var navIsActive: Bool
    @Binding var vesPin: String
    @Binding var player: Player
    @State var game = false
    @State var playerToPick: String = ""
    @State var players = [DataSnapshot]()
    @State var showWordPicking = false
    @State var popOffset = UIScreen.main.bounds.height
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            if !game {
                VStack(spacing: 0) {
                    
                    // Header titles
                    RoomHeader(title: "In The Room", players: $players, onMarkClick: {
                        DatabaseManager.shared.removeFromRoom(with: player, from: vesPin)
                        self.navIsActive = false
                    })
                    .padding(.bottom, 50)
 
                    // Orange banner with current vesPin
                    VesPinBadge(vesPin: $vesPin)
                    
                    // Room player cards
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach($players, id: \.key) { p in
                                RoomPlayerCell(player: p)
                            }
                        }
                        .padding(.top, 50)
                    }
                    .padding(.bottom, 50)
                    
                    
                    // Continue button for room leaders
                    RoomContinue(onButtonClick: {
                        assignPlayers(vesPin: vesPin) {
                            DatabaseManager.shared.startWordPicking(in: vesPin)
                        }
                    })
                    .offset(x: players.count > 1 && isLeaderLocal(name: player.name) ? 0 : UIScreen.main.bounds.width + 500)
                    .disabled(players.count <= 1 || !isLeaderLocal(name: player.name))
                    .animation(.spring())
                    
                    Spacer()
                    
                }
                .padding(.top, 30)
                .padding(.horizontal, 25)
            } else {
                GameView(navIsActive: $navIsActive, vesPin: $vesPin, player: $player, players: $players)
            }
            
            SneakyView(isShowing: $showWordPicking, vesPin: $vesPin, player: $player, players: $players)
                .offset(y: showWordPicking ? 0 : popOffset)
                .animation(.easeInOut, value: showWordPicking)
            
            
        }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            UIApplication.shared.statusBarStyle = .darkContent
            self.addObservers()
        }
    }
    
    func addObservers() {
        self.onPlayerAddObserve()
        self.onPlayerRemoveObserve()
        self.onPlayerChangeObserve()
        self.onRoomChangeObserve()
    }
    
    func onPlayerAddObserve() {
        DatabaseManager.shared.onPlayerAdd(on: vesPin, completion: { snapshot in
            print("\(snapshot.key) Added")
            players.append(snapshot)
            print("Players in room: \(players.count)")
        })
    }
    
    func onPlayerRemoveObserve() {
        DatabaseManager.shared.onPlayerRemove(on: vesPin, completion: { removedPlayer in
            
            // Remove player locally
            players = players.filter{ $0.key != removedPlayer.key }
            print("\(removedPlayer.key) Removed")
            
//                let wasLeader = removedPlayer.childSnapshot(forPath: "leader").value as! Int == 1
//
//                if wasLeader {
//                    guard let randomPlayer = players.randomElement() else {
//                        print("No players in room")
//                        return
//                    }
//
//                    let randomPlayerName = randomPlayer.key
//                    print("Giving leadership to \(String(randomPlayerName)) in \(vesPin)")
//
//                    // Set new leader
//                    DatabaseManager.shared.giveLeadership(to: String(randomPlayerName), in: vesPin)
//                }
            print("Players in room: \(players.count)")
        })
    }
    
    func onPlayerChangeObserve() {
        DatabaseManager.shared.onPlayerChange(on: vesPin, completion: { snapshot in
            print("\(snapshot.key) Changed")
            if let index = players.firstIndex(where: {$0.key == snapshot.key}) {
                players[index] = snapshot
            }
            DatabaseManager.shared.nextTurn(in: vesPin, completion: { updatedPlayers in
                self.players = updatedPlayers
            })
            
            if self.showWordPicking {
                if players.filter { $0.childSnapshot(forPath: "word").value as! String == "" }.count == 0 {
                    DatabaseManager.shared.startGame(in: vesPin)
                    DatabaseManager.shared.endWordPicking(in: vesPin)
                }
            }
        })
    }
    
    func onRoomChangeObserve() {
        DatabaseManager.shared.onRoomChange(on: vesPin, completion: { snapshot in
            if snapshot.key == "gameOn" {
                self.game = snapshot.value as! Bool
            }
            
            if snapshot.key == "showWordPick" {
                self.showWordPicking = snapshot.value as! Bool
            }
            
            print("\(snapshot.key) Changed (ROOM)")
        })
    }
    
    func getPlayerLocal(name: String) -> DataSnapshot? {
        print("player: \(players.filter({$0.key == name}).first)")
        return players.filter({$0.key == name}).first
    }
    
    func isLeaderLocal(name: String) -> Bool {
        guard let p = getPlayerLocal(name: name) else {
            return false
        }
        
        return p.childSnapshot(forPath: "leader").value as! Int == 1
    }
    
    func assignPlayers(vesPin: String, completion: @escaping () -> Void) {

        DatabaseManager.shared.getPlayers(in: vesPin) { dbPlayers in
            var availableTo = dbPlayers.filter { $0.childSnapshot(forPath: "wordTo").value as! String == "" }

            
            if availableTo.count <= 1 { return }
            
            // Make sure that the player we're giving to ARE NOT the ones we are receiving from.
            
            var rT = Int(arc4random_uniform(UInt32(availableTo.count))) // Random TO index
            var randomTo = availableTo[rT] // Random player that has no TO
            
            for (i, p) in dbPlayers.enumerated() {
                
                if availableTo.count == 0 { return }
                rT = Int(arc4random_uniform(UInt32(availableTo.count)))
                randomTo = availableTo[rT]
                
                while p.key == randomTo.key {
                    rT = Int(arc4random_uniform(UInt32(availableTo.count)))
                    randomTo = availableTo[rT]
                }
                
                DatabaseManager.shared.linkPlayers(giver: p.key, receiver: randomTo.key, in: vesPin)
                availableTo = availableTo.filter { $0.key != randomTo.key}
            }
            
            completion()
        }
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView(navIsActive: .constant(true), vesPin: .constant("KODAS"), player: .constant(Player(name: "", word: "", wordTo: "", wordFrom: "")))
    }
}
