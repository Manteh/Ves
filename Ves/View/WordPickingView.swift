//
//  WordPickingView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-23.
//

import SwiftUI

struct WordPickingView: View {
    
    @GestureState private var isHolding = false
    @State var wordSuggestion = "Elon Musk"
    @State var playerToPick = ""
    @State var pickedWord: String = ""
    @State var wordMaxLength: Int = 10
    @State var keyboardShowing: Bool? = false
    @State var t1: Bool = false
    @State var t2: Bool = false
    @State var t3: Bool = false
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 65) {
                Text("Give Player A Word")
                    .font(.system(size: 35, weight: .heavy, design: .rounded))
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 65) {
                        
                        VStack(spacing: 10) {
                            Image(systemName: "figure.stand.line.dotted.figure.stand")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("Make sure this player isn’t looking at your screen")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .offset(y: t1 ? 0 : 1000)
                        
                        VStack(spacing: 10) {
                            Image(systemName: "eyes.inverse")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Text("Hold the button below to view the name of the player.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                            
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(Color(hex: "333333"), style: .init(lineWidth: 1, lineCap: .round, lineJoin: .miter, miterLimit: 29, dash: [2], dashPhase: 2))
                                .frame(minHeight: 60 + 11.2)
                                .background (
                                    ZStack {
                                        Color(hex: "F2F2F6")
                                        HStack(spacing: 10) {
                                            if isHolding {
                                                Text(playerToPick.uppercased())
                                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                            } else {
                                                Image(systemName: "eye.fill")
                                                Text("Hold To View")
                                            }
                                        }
                                        .foregroundColor(Color(hex: "333333"))
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    }
                                )
                                .padding(.top, 20)
                                .gesture(LongPressGesture(minimumDuration: 0.01).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local)).updating($isHolding) { value, state, _ in
                                        switch value {
                                            case .second(true, nil):
                                                state = true
                                            default:
                                                break
                                        }
                                })
                        }
                        .offset(y: t2 ? 0 : 1000)
                        
                        VStack(alignment: .center, spacing: 10) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("Give this player a word to guess. What about ")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                            + Text("\(wordSuggestion)?")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            
                            Button(action: { keyboardShowing = true}, label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(orangeGradientLeftRight)
                                    .frame(minHeight: 60 + 11.2)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Text(pickedWord.count == 0 ? wordSuggestion : pickedWord)
                                            Spacer()
                                        }
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(pickedWord.count == 0 ? 0.1 : 1))
                                        .padding(.horizontal, 20)
                                    )
                                    .background(
                                        CustomTextField(text: $pickedWord,
                                                        nextResponder: .constant(nil),
                                                        isResponder: $keyboardShowing,
                                                        textLimit: $wordMaxLength,
                                                        isSecured: false,
                                                        keyboard: .default)
                                            .font(.system(size: 40, weight: .regular, design: .rounded))
                                            .frame(width: .infinity, height: 60 + 11.2)
                                            .background(Color.white.opacity(0.1))
                                            .opacity(0)
                                    )
                            })
                            .padding(.top, 20)
                        }
                        .offset(y: t3 ? 0 : 1000)

                    }
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 15)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring()) {
                                t1 = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring()) {
                                    t2 = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring()) {
                                        t3 = true
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                Spacer()
            }
            .foregroundColor(Color(hex: "333333"))
            .padding(.top, 30)
            .padding(.horizontal, 30)
            
        }
        .onAppear {
            UIApplication.shared.setStatusBarStyle(.darkContent, animated: false)
        }
    }
}

struct WordPickingView_Previews: PreviewProvider {
    static var previews: some View {
        WordPickingView()
    }
}
