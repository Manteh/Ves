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
    @State var players: [DataSnapshot] = []
    
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
                    
                    // Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(players.count) PLAYERS")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .selfSizeMask(orangeGradientText)
                        HStack {
                            Text("In The Room")
                                .font(.system(size: 35, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "333333"))
                            Spacer()
                            Button(action: {
                                DatabaseManager.shared.removeFromRoom(with: player, from: vesPin)
                                self.navIsActive = false
                            }, label: {
                                Image(systemName: "xmark.square.fill")
                                    .resizable()
                                    .foregroundColor(.black.opacity(0.1))
                            })
                            .frame(width: 25, height: 25)
                        }
                    }
                    .padding(.bottom, 50)
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(orangeGradientLeftRight)
                            .frame(height: 60 + 11.2)
                            .overlay(
                                HStack {
                                    Text("VES PIN")
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Image(systemName: "circles.hexagongrid.fill")
                                        Text("\(vesPin)")
                                    }
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            )
                    }
                    
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
                                .opacity(0.1)
                        }

                        Button(action: {
                        
                            DatabaseManager.shared.startGame(in: vesPin)

                            //print("Players: \(players.count)")
                            //assignPlayers()
                            //playerToPick = room!.players.first{ $0.id == playerId }!.wordTo!
                            //withAnimation(.spring()) {
                            //    isShowingWordPicker = true
                            //}
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
                .padding(.horizontal, 30)
            } else {
                GameView(navIsActive: $navIsActive, vesPin: $vesPin, player: $player, players: $players)
            }
        }
        .preferredColorScheme(.light)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            UIApplication.shared.setStatusBarStyle(.darkContent, animated: false)
            
            //print("Is leader \(isLeader(playerName: player.name))")
            
            DatabaseManager.shared.onPlayerAdd(on: vesPin, completion: { snapshot in
                print("\(snapshot.key) Added")
                players.append(snapshot)
            })
            
            DatabaseManager.shared.onPlayerRemove(on: vesPin, completion: { removedPlayer in
                
                // Remove player locally
                players = players.filter{ $0.key != removedPlayer.key }
                print("\(removedPlayer.key) Removed")
                
                let wasLeader = removedPlayer.childSnapshot(forPath: "leader").value as! Int == 1
                
                if wasLeader {
                    guard let randomPlayer = players.randomElement() else {
                        print("No players in room")
                        return
                    }
                    
                    let randomPlayerName = randomPlayer.key
                    print("Giving leadership to \(String(randomPlayerName)) in \(vesPin)")
                    
                    // Set new leader
                    DatabaseManager.shared.giveLeadership(to: String(randomPlayerName), in: vesPin)
                }

            })
            
            DatabaseManager.shared.onPlayerChange(on: vesPin, completion: { snapshot in
                print("\(snapshot.key) Changed")
                if let index = players.firstIndex(where: {$0.key == snapshot.key}) {
                    players[index] = snapshot
                }
            })
            
            DatabaseManager.shared.onRoomChange(on: vesPin, completion: { snapshot in
                if snapshot.key == "gameOn" {
                    self.game = snapshot.value as! Bool
                }
                print("\(snapshot.key) Changed (ROOM)")
            })
        
        }
        .onDisappear {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
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
}
    
//    func assignPlayers() {
//
//        var availableTo = room!.players.filter { $0.wordTo == nil }
//        
//        if availableTo.count == 0 { return }
//        
//        // Make sure that the player we're giving to ARE NOT the ones we are receiving from.
//        
//        var rT = Int(arc4random_uniform(UInt32(availableTo.count)))
//        var randomTo = availableTo[rT] // Random player that has no TO
//        
//        // Make sure that the player we're giving to ARE NOT the ones we are receiving from.
//        
//        for (i, p) in room!.players.enumerated() {
//            
//            if availableTo.count == 0 { return }
//            rT = Int(arc4random_uniform(UInt32(availableTo.count)))
//            randomTo = availableTo[rT]
//            
//            while p.name == randomTo.name {
//                rT = Int(arc4random_uniform(UInt32(availableTo.count)))
//                randomTo = availableTo[rT]
//            }
//            
//            let rIndex = room!.players.firstIndex { $0.name == randomTo.name}!
//            
//            room!.players[i].wordTo = randomTo.name
//            room!.players[rIndex].wordFrom = room!.players[i].name
//            availableTo = availableTo.filter { $0.name != randomTo.name }
//            
//        }
//        
//        for p in room!.players {
//            print("Player [\(p.name)] givingTo [\(p.wordTo)] and receiving from [\(p.wordFrom)]")
//        }
//    }
    
    /*func isLeader(playerName: String) -> Bool {
        let thisPlayer = self.players.filter { $0.key == playerName} as! DataSnapshot
        
        return thisPlayer.childSnapshot(forPath: "leader").value as! Bool
    }*/

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView(navIsActive: .constant(true), vesPin: .constant("KODAS"), player: .constant(Player(name: "", word: "", wordTo: "", wordFrom: "")))
    }
}
