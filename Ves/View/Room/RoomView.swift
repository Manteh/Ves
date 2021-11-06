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
    @State var cpIndex = 0
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
                    
                    RoomHeader(title: "In The Room", players: $players, onMarkClick: {
                        DatabaseManager.shared.removeFromRoom(with: player, from: vesPin)
                        self.navIsActive = false
                    })
                    .padding(.bottom, 50)
 
                    VesPinBadge(vesPin: $vesPin)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach($players, id: \.self) { p in
                                RoomPlayerCell(player: p)
                            }
                        }
                        .padding(.top, 50)
                    }
                    .padding(.bottom, 50)
                    
                    VStack(alignment: .center) {

                        HStack {
                            Text("EVERYONE READY?")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "333333"))
                                .opacity(0.1)
                        }

                        Button(action: {
                            assignPlayers(vesPin: vesPin) {
                                DatabaseManager.shared.startWordPicking(in: vesPin)
                            }
                        }, label: {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(orangeGradientLeftRight)
                                .frame(maxHeight: 60 + 11.2)
                                .overlay(
                                    HStack {
                                        Image(systemName: "arrow.right").opacity(0)
                                        Spacer()
                                        Text("CONTINUE")
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                )
                        })

                    }
                    .offset(x: isLeaderLocal(name: player.name) ? 0 : 500)
                    .animation(.spring(), value: isLeaderLocal(name: player.name))
                    
                    Spacer()
                    
                }
                .padding(.top, 30)
                .padding(.horizontal, 25)
            } else {
                GameView(navIsActive: $navIsActive, vesPin: $vesPin, player: $player, players: $players, cpIndex: $cpIndex)
            }
            
            SneakyView(isShowing: $showWordPicking, vesPin: $vesPin, player: $player, players: $players)
                .offset(y: showWordPicking ? 0 : popOffset)
                .animation(.easeInOut, value: showWordPicking)
            
            
        }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            //print("Is leader \(isLeader(playerName: player.name))")
            
            UIApplication.shared.statusBarStyle = .darkContent
            
            DatabaseManager.shared.onPlayerAdd(on: vesPin, completion: { snapshot in
                print("\(snapshot.key) Added")
                players.append(snapshot)
                print("Players in room: \(players.count)")
            })
            
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
