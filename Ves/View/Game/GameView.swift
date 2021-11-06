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
    @Binding var cpIndex: Int
    @State var igPlayers = [Player(name: "STEVE"), Player(name: "ELON"), Player(name: "BOB")]
    @State var passClicked = false
    @State var turnsMade = 0
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                RoomHeader(title: "Guessing", players: $players, onMarkClick: {
                    DatabaseManager.shared.removeFromRoom(with: player, from: vesPin)
                    self.navIsActive = false
                })
                
                ScrollView(showsIndicators: false) {
                    ForEach($players, id: \.self) { p in
                        if players.index(of: p.wrappedValue) == 0 {
                            currentTurnerView(currentTurnPlayer: p, localPlayer: $player, vesPin: $vesPin, passClicked: $passClicked)
                                .onChange(of: passClicked, perform: { newValue in
                                    DatabaseManager.shared.turnMadeBy(name: p.wrappedValue.key, in: vesPin, completion: { updatedPlayers in
                                        print("Updated players: \(updatedPlayers)")
                                        self.players = updatedPlayers
                                        self.passClicked = false
                                    })
                                })
                        } else {
                            if players.index(of: p.wrappedValue) == 1 {
                                NextSplitter()
                            }
                            playerCardView(player: p, localPlayer: $player)
                        }
                    }
                }
                .onAppear {
                    print("GameView appeared")
                }
                
                Spacer()
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 25)
        }
        .preferredColorScheme(.light)
    }
}

struct currentTurnerView: View {

    @Binding var currentTurnPlayer: DataSnapshot
    @Binding var localPlayer: Player
    @Binding var vesPin: String
    @Binding var passClicked: Bool
    @State var controlOpacity = 1
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text("\(currentTurnPlayer.key)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    
                    if isLocalTurn() {
                        Text("  •  You")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                
                if isLocalTurn() {
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
                        
                        Button(action: {
                            // Remove playerObj at index 0 at put it last
                            //DatabaseManager.shared.nextPlayerTurn(in: vesPin)
                            passClicked = true
                        }, label: {
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
                    holdToView(player: $currentTurnPlayer)
                }
            }
            .padding(30)
            .background (
                RoundedRectangle(cornerRadius: 15)
                    .fill(playerColor(player: currentTurnPlayer))
            )
            
        }
        .padding(.top, 50)
        
    }
    
    func isLocalTurn() -> Bool {
        return localPlayer.name == currentTurnPlayer.key
    }
    
    func playerColor(player: DataSnapshot) -> LinearGradient {
        if currentTurnPlayer.childSnapshot(forPath: "color").value as! String == "orange" {
            return orangeGradientBG
        } else if currentTurnPlayer.childSnapshot(forPath: "color").value as! String == "blue" {
            return blueGradientBG
        }
        return LinearGradient.init(colors: [.white], startPoint: .top, endPoint: .bottom)
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

struct Safe<T: RandomAccessCollection & MutableCollection, C: View>: View {
    typealias BoundElement = Binding<T.Element>
    private let binding: BoundElement
    private let content: (BoundElement) -> C

    init(_ binding: Binding<T>, index: T.Index, @ViewBuilder content: @escaping (BoundElement) -> C) {
        self.content = content
        self.binding = .init(get: { binding.wrappedValue[index] },
                             set: { binding.wrappedValue[index] = $0 })
    }

    var body: some View {
        content(binding)
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
        GameView(navIsActive: .constant(true), vesPin: .constant("XXXXXX"), player: .constant(Player(name: "JXS")), players: .constant([DataSnapshot.init()]), cpIndex: .constant(0))
    }
}

