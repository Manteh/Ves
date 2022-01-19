//
//  GameRules.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-08.
//

import SwiftUI

struct GameRules: View {
    
    @State var showGameRules = false
    
    var body: some View {
        Button(action: {
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
    }
}

struct GameRulesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let gameRules = "VES is an in(ves)tigative party game that brings you and your family & friends together.\n\nThe purpose of the game is to try to guess a word that you were given by another player in the same room (e.g. your family member).\n\nEvery player has to think of a random word (e.g. Snake, Apple or King Kong) to give to another player that is randomly chosen to you.\n\nAfter every player has received their words, the game will begin. Each player will have their turn to ask questions (Yes-No questions only).\n\nEvery player can see what words the other players have. Questions that are being asked can be answered by anyone playing.\n\nPlayer is only allowed to ask a question if it’s their turn. Player is allowed to ask questions about their word until the answer to the most recent question is NO. If the answer is NO, the player has to pass their turn to the next player in line.\n\nPlayer is allowed to guess the word, but in failure to do so, the player has to pass their turn to another player in line.\n\nDuring each turn, the player has the ability to reveal their word by pressing a button. It should be pressed when the player guesses the word, but also when the player decides to give up or leave the game.\n\nThe game continues until there is only one player left to guess their word. The last player has to reveal itself and the game summary is displayed."

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



