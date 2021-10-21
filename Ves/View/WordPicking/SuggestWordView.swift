//
//  SuggestWordView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-19.
//

import SwiftUI

struct SuggestWordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var clickedContinue = false
    @State var navigationActive = false
    @State var pickedWord = ""
    @State var keyboardShowing: Bool? = false
    @State var wordMaxLength = 12
    let wordSuggestion = "FREDDIE MERCURY"
    
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
                
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if !keyboardShowing! {
                            Image("suggest")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Suggest a Word")
                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(hex: "333333"))
                                Spacer()
                                Button(action: {
                                    withAnimation(.spring()) {
                                        keyboardShowing! = false
                                    }
                                }, label: {
                                    Image(systemName: "checkmark.square.fill")
                                        .font(.system(size: 30, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "333333"))
                                })
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Give this player a word to guess.")
                                Text("What about ")
                                +
                                Text("Freddie Mercury?")
                                    .bold()
                            }
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "333333").opacity(0.25))
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    keyboardShowing! = true
                                    pickedWord = ""
                                }
                            }, label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(blueGradientButton)
                                    .frame(height: 60 + 11.2)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Text(pickedWord.count == 0 ? wordSuggestion : pickedWord)
                                            Spacer()
                                        }
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
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
                                            .disabled(keyboardShowing! ? false : true)
                                    )
                            })
                            .padding(.top, 20)
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    clickedContinue = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring()) {
                                        keyboardShowing! = false
                                        clickedContinue = false
                                    }
                                }
                            }, label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white)
                                    .frame(height: 60 + 11.2)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Text("Continue")
                                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                                .foregroundColor(Color(hex: "333333"))
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                    )
                                    .offset(x: keyboardShowing! && pickedWord.count >= 3 && !clickedContinue ? 0 : UIScreen.main.bounds.width * 2)
                            })
                            .animation(.spring())
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 95)
                    }
                    .offset(y: !keyboardShowing! ? 60 + 11.2 : 60)
                }
                .overlay(
                    VStack {
                        HStack {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(hex: "333333"))
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                )
            }
        }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct SuggestWordView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestWordView()
    }
}
