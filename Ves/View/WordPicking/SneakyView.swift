//
//  SneakyView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-18.
//

import SwiftUI
import FirebaseDatabase

struct SneakyView: View {
    @GestureState var isHolding = false
    @State var navigationActive = false
    @Binding var isShowing: Bool
    @Binding var vesPin: String
    @Binding var player: Player
    @Binding var players: [DataSnapshot]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F6")
                    .edgesIgnoringSafeArea(.all)
                    .background(
                        NavigationLink(destination: SuggestWordView(isShowing: $isShowing, vesPin: $vesPin, player: $player, players: $players), isActive: $navigationActive) {
                            EmptyView()
                        }
                        .isDetailLink(false)
                    )
                
                VStack {
                    Image("sneaky")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 50)
                        .edgesIgnoringSafeArea(.all)
                        .offset(y: 100)
                    Spacer()
                }
                .frame(width: .infinity, height: .infinity)
                    
                VStack {
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Be Sneaky")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "333333"))
                            Spacer()
                            Button(action: {
                                self.navigationActive = true
                            }, label: {
                                Image(systemName: "arrow.forward.square.fill")
                                    .font(.system(size: 30, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "333333"))
                            })
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Make sure this player is not looking at your screen, while you choose a word for them.")
                            Text("Hold the button below to view the name of the player.")
                        }
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "333333").opacity(0.5))
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(blueGradientButton)
                            .frame(height: 60 + 11.2)
                            .scaleEffect(isHolding ? 1.1 : 1)
                            .animation(.spring(), value: isHolding)
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !isHolding {
                                        HStack {
                                            Image(systemName: "eye.fill")
                                            Text("Hold To View")
                                        }
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    } else {
                                        Text(self.getWordToPlayerName())
                                            .font(.system(size: 25, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            )
                            .padding(.vertical, 20)
                            .gesture(LongPressGesture(minimumDuration: 0.2).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local)).updating($isHolding) { value, state, _ in
                                    switch value {
                                        case .second(true, nil):
                                            state = true
                                        default:
                                            break
                                    }
                            })
                        
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 70)
                }
                .frame(height: .infinity)
            
            }
            .colorScheme(.light)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }

    }
    
    func getWordToPlayerName() -> String {
        return (players.filter{$0.key == player.name})[0].childSnapshot(forPath: "wordTo").value as! String
    }
}
