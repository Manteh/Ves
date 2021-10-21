//
//  GameView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-19.
//

import SwiftUI
import FirebaseDatabase

struct GameView: View {
    
    @Binding var navIsActive: Bool
    @Binding var vesPin: String
    @Binding var player: Player
    @Binding var players: [DataSnapshot]
    
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
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        VStack(spacing: 40) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Text("JACK  •  You")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                
                                Spacer()
                            }
                            .foregroundColor(.white)
                            
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Reveal me")
                                    Spacer()
                                    Image(systemName: "eyes.inverse")
                                }
                                .padding(15)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.white.opacity(0.1))
                                )
                                
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
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                            .fill(orangeGradientBG)
                        )
                        
                    }
                    .padding(.top, 50)
                    
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
                    
                    VStack {
                        VStack(spacing: 40) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Text("Bob")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                
                                Spacer()
                            }
                            .foregroundColor(.white)
                            
                            VStack(spacing: 20) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "eye.fill")
                                    Text("Hold To View")
                                    Spacer()
                                }
                                .opacity(0.5)
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
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                            .fill(blueGradientBG)
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 30)
        }
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

