//
//  WordRevealView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-07.
//

import SwiftUI
import FirebaseDatabase

struct WordRevealView: View {
    
    @Binding var player: DataSnapshot // Player that reveals is local
    @Binding var players: [DataSnapshot]
    let onButtonClick: () -> Void
    
    var body: some View {
        ZStack {
            Color.init(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Spacer()
                
                // Header
                VStack(spacing: 20) {
                    orangeGradientTopBottom
                        .frame(height: 30)
                        .mask(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                        )
                    orangeGradientTopBottom
                        .frame(height: 30)
                        .mask(
                            Text("Word Reveal")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .kerning(2)
                        )
                }
                
                Spacer()
                
                // Content
                VStack(spacing: 80) {
                    VStack(alignment: .center, spacing: 6) {
                        Text("Player")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333").opacity(0.25))
                        Text(player.childSnapshot(forPath: "name").value as! String)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333").opacity(0.75))
                    }
                    
                    VStack(alignment: .center, spacing: 6) {
                        orangeGradientTopBottom
                            .frame(height: 15)
                            .mask(
                                Text("Word")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                            )
                        Text(player.childSnapshot(forPath: "word").value as! String)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333"))
                    }
                    
                    VStack(alignment: .center, spacing: 6) {
                        Text("Given by")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333").opacity(0.25))
                        Text(player.childSnapshot(forPath: "wordFrom").value as! String)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333").opacity(0.75))
                    }
                }
                
                Spacer()
                
                // Footer
                
                VStack(spacing: 20) {
                    Text("\(players.count) players remaining")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.init(hex: "333333").opacity(0.25))
                    
                    Button(action: onButtonClick, label: {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(orangeGradientLeftRight)
                            .frame(height: 60 + 11.2)
                            .overlay(
                                HStack {
                                    Image(systemName: "arrow.right").opacity(0)
                                    Spacer()
                                    Text(players.count == 0 ? "GAME SUMMARY" : "CONTINUE")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            )
                    })
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
    }
}

