//
//  HomeView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import SwiftUI

struct HomeView: View {
    
    @State var navIsActive: Bool = false
    @State private var showGameRules = false
    @State var createRoomClicked = false
    @State var vesPin = ""
        
    var body: some View {
        NavigationView {
            ZStack {
                Color.init(hex: "F2F2F6")
                
                ZStack {
                    PlayerView()
                        .frame(width: screenWidth())
                    Color.black.opacity(0.5)
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Button(action: {
                        vesPin = ""
                        showGameRules.toggle()
                    }, label: {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: "BFBFBF").opacity(0.1))
                            .frame(maxHeight: 63)
                            .overlay(
                                HStack {
                                    Spacer()
                                    Text("Game Rules of VES")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            )
                    })
                        .sheet(isPresented: $showGameRules){
                            GameRulesView()
                        }

                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        orangeGradientTopBottom
                            .frame(height: 50)
                            .mask(
                                Label("VES", systemImage: "leaf.fill")
                                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                            )
                        HStack {
                            Text("IN").kerning(1) +
                            Text("VES").kerning(1)
                                .fontWeight(.heavy) +
                            Text("TIGATIVE PARTY GAME").kerning(1)
                        }
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color(hex: "C8C8C8"))
                    }
                    
                    Spacer()

                    VStack(spacing: 20) {
                    
                        Button(action: {
                            vesPin = ""
                            self.createRoomClicked.toggle()
                        }, label: {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(orangeGradientLeftRight)
                                .frame(maxHeight: 63)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Text("Create a new ")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .regular, design: .rounded))
                                        + Text("VES")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                                        Spacer()
                                    }
                                    .overlay(
                                        Image(uiImage: #imageLiteral(resourceName: "party-face-emoji"))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30)
                                            .offset(x: -140)
                                    )
                                    .padding(.horizontal, 20)
                                )
                                .background(
                                    NavigationLink(destination: NamePickView(navIsActive: $createRoomClicked, vesPin: $vesPin), isActive: $createRoomClicked) {
                                        EmptyView()
                                    }
                                    .isDetailLink(false)
                                )
                        })
                        
                        
                        Button(action: {}, label: {
                            NavigationLink(destination: VesPinView(navIsActive: self.$navIsActive), isActive: self.$navIsActive) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white)
                                    .frame(maxHeight: 63)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Text("Join with ")
                                                .foregroundColor(Color(hex: "333333"))
                                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                            + Text("VES Pin")
                                                .foregroundColor(Color(hex: "333333"))
                                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                            Spacer()
                                        }
                                        .overlay(
                                            Image(uiImage: #imageLiteral(resourceName: "waving-hand-emoji"))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 30)
                                                .offset(x: 140)
                                        )
                                        .padding(.horizontal, 20)
                                    )
                            }
                            .isDetailLink(false)
                        })
                        
                    }
                    
                    HStack {
                        VStack {
                            Text("By continuing you agree to our ")
                            HStack(spacing: 5) {
                                Link(destination: URL(string: "https://www.apple.com")!, label: {
                                    Text("Terms")
                                        .fontWeight(.bold)
                                })
                                    .padding(0)
                                Text("and")
                                Link(destination: URL(string: "https://www.apple.com")!, label: {
                                    Text("Conditions")
                                        .fontWeight(.bold)
                                })
                            }
                        }
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .foregroundColor(Color(hex: "FFFFFF").opacity(0.5))
                        .multilineTextAlignment(.center)
                    }
                    .frame(width: 240)
                    .padding(.top, 50)
                    
                }
                .padding(.horizontal, 25)
                .padding(.top, safeTop() + 20)
                .padding(.bottom, safeBottom() + 20)
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

struct GameRulesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let gameRules = "VES is an in(ves)tigative party game that brings you and your family & friends together.\n\nThe purpose of the game is to try to guess a word that you were given by another player in the same room (e.g. your family member).\n\nEvery player has to think of a random word (e.g. Snake, Apple or King Kong) to give to another player that is randomly chosen to you.\n\nAfter every player has received their words, the game will begin. Each player will have their turn to ask questions (Yes-No questions only).\n\nEvery player can see what words the other players have. Questions that are being asked can be answered by anyone playing.\n\nPlayer is only allowed to ask a question if it’s their turn. Player is allowed to ask questions about their word until the answer to the most recent question is NO. If the answer is NO, the player has to pass their turn to the next player in line.\n\nPlayer is allowed to guess the word, but in failure to do so, the player has to pass their turn to another player in line.\n\nDuring each turn, the player has the ability to reveal their word by pressing a button. It should be pressed when the player guesses the word, but also when the player decides to give up or leave the game.\n\nThe game continues until there is only one player left to guess their word. The word of the last player is revealed automatically."

    var body: some View {
        ZStack {
            Color(hex: "F2F2F6").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("WELCOME TO")
                            .foregroundColor(Color(hex: "333333"))
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .kerning(2)
                        orangeGradientTopBottom
                            .frame(height: 50)
                            .mask(
                                Text("VES")
                                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                                    .kerning(2)
                            )
                    }
                    .padding(.bottom, 50)
                    
                    VStack {
                        Text(gameRules)
                            .foregroundColor(Color(hex: "333333").opacity(0.5))
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                    }
                }
                .padding(.top, 50)
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 30)

        }
    }
}

func screenWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

func safeBottom() -> CGFloat {
    if #available(iOS 13.0, *) {
        let window = UIApplication.shared.windows.first
        let bottomPadding = window!.safeAreaInsets.bottom
        return bottomPadding
    }
    return 0
}

func safeTop() -> CGFloat {
    if #available(iOS 13.0, *) {
        let window = UIApplication.shared.windows.first
        let topPadding = window!.safeAreaInsets.top
        return topPadding
    }
    return 0
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
