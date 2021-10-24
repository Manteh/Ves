//
//  GameView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-19.
//

import SwiftUI
import FirebaseDatabase

struct GameView: View {
    
    @GestureState private var isHolding = false
    @Binding var navIsActive: Bool
    @Binding var vesPin: String
    @Binding var player: Player
    @Binding var players: [DataSnapshot]
    @State var igPlayers = [Player(name: "STEVE"), Player(name: "ELON"), Player(name: "BOB")]
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(players.count) PLAYERS")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .selfSizeMask(orangeGradientText)
                    HStack {
                        Text("Guessing")
                            .font(.system(size: 35, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "333333"))
                        Spacer()
                        Button(action: {
                            DatabaseManager.shared.nextPlayerTurn(in: vesPin)
                            //DatabaseManager.shared.removeFromRoom(with: player, from: vesPin)
                            //self.navIsActive = false
                        }, label: {
                            Image(systemName: "xmark.square.fill")
                                .resizable()
                                .foregroundColor(.black.opacity(0.1))
                        })
                        .frame(width: 25, height: 25)
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    ForEach(0..<players.count) { i in
                        if i == 0 {
                            localPlayerTurnView(player: $players[i], localPlayer: $player)
                            
                            // NEXT splitter
                            HStack {
                                Line()
                                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                                    .frame(height: 1)
                                Text(" NEXT ")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                Line()
                                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                                    .frame(height: 1)
                            }
                            .opacity(0.1)
                            .padding(.vertical, 30)
                        } else {
                            playerCardView(player: $players[i], localPlayer: $player)
                        }
                    }
                }
                .onAppear {
                    print("GameView appeared")
                    DatabaseManager.shared.randomWordsAll(in: vesPin, completion: {
                        DatabaseManager.shared.getPlayers(in: vesPin, completion: { snapshot in
                            players = snapshot
                            print("player1: \(players[0])")
                        })
                    })
                }
                
                Spacer()
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 30)
        }
        .preferredColorScheme(.light)
    }
}

struct localPlayerTurnView: View {
    
    @Binding var player: DataSnapshot
    @Binding var localPlayer: Player
    @State var controlOpacity = 0
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text("\(player.key)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    
                    if localPlayer.name == player.key {
                        Text("  •  You")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                
                if localPlayer.name == player.key {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Reveal me")
                            Spacer()
                            Image(systemName: "eyes")
                        }
                        .padding(15)
                        .padding(.vertical, 5)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.white.opacity(0.1))
                        )
                        
                        Button(action: { }, label: {
                            HStack {
                                Text("Pass")
                                    .selfSizeMask(orangeGradientText)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .selfSizeMask(orangeGradientText)
                            }
                            .padding(15)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(.white)
                            )
                        })
                    }
                    .opacity(Double(controlOpacity))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                } else {
                    holdToView(player: $player)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                .fill(orangeGradientBG)
            )
            
        }
        .padding(.top, 50)
        
    }
}

struct playerCardView: View {
    @Binding var player: DataSnapshot
    @Binding var localPlayer: Player
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text(player.key)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    if localPlayer.name == player.key {
                        Text("•  You")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                
                if localPlayer.name != player.key {
                    holdToView(player: $player)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                .fill(blueGradientBG)
            )
        }
    }
}

struct holdToView: View {
    @GestureState var isHolding = false
    @Binding var player: DataSnapshot
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                if !isHolding {
                    Image(systemName: "eye.fill")
                    Text("Hold To View")
                } else {
                    Text(player.childSnapshot(forPath: "word").value as! String)
                }
                Spacer()
            }
            .opacity(isHolding ? 1 : 0.5)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .padding(15)
            .padding(.vertical, 5)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [3]))
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white.opacity(0.1)))
            )
            .gesture(LongPressGesture(minimumDuration: 0.1).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local)).updating($isHolding) { value, state, _ in
                    switch value {
                        case .second(true, nil):
                            state = true
                        default:
                            break
                    }
            })
        }
        .font(.system(size: 15, weight: .bold, design: .rounded))
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(navIsActive: .constant(true), vesPin: .constant("XXXXXX"), player: .constant(Player(name: "JXS")), players: .constant([DataSnapshot.init()]))
    }
}

