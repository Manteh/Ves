//
//  NamePickView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-22.
//

import SwiftUI
import AudioToolbox

struct NamePickView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var navIsActive: Bool
    @State var buttonPressed: Bool = false
    @State var placeholder = "John"
    @State var name = ""
    @State var keyboardShowing: Bool? = false
    @State var maxNameLength = 10
    @State var showButton = false
    @Binding var vesPin: String
    @State var player = Player(name: "", word: "", wordTo: "", wordFrom: "")
    
    @State var pinAttempts: Int = 0
    
    var body: some View {
        ZStack {
            blueGradientBG
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 50) {
            
                // Back to Home Button
                VStack(spacing: 50) {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 50) {
                    
                        VStack(alignment: .leading) {
                            Text("WHAT’S YOUR")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Text("NAME?")
                                .font(.system(size: 50, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: .infinity, height: 60 + 11.2)
                            .foregroundColor(.white.opacity(0.1))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                            .overlay(
                                HStack {
                                    Text(name.count == 0 ? placeholder : name)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(name.count == 0 ? 0.5 : 1))
                                    Spacer()
                                }
                                .padding(.horizontal, 15)
                            )
                            .modifier(Shake(animatableData: CGFloat(pinAttempts)))
                            .background(
                                CustomTextField(text: $name,
                                                nextResponder: .constant(nil),
                                                isResponder: $keyboardShowing,
                                                textLimit: $maxNameLength,
                                                isSecured: false,
                                                keyboard: .default)
                                    .font(.system(size: 40, weight: .regular, design: .rounded))
                                    .frame(width: .infinity, height: 60 + 11.2)
                                    .background(Color.white.opacity(0.1))
                                    .opacity(0)
                            )
                        
                    }
                }
                
                NavigationLink(destination: RoomView(navIsActive: $navIsActive, vesPin: $vesPin, player: $player), isActive: $buttonPressed) {
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                        impactMed.impactOccurred()
                        /// Check if vesPin is empty, meaning player wants to create a new room
                        if name.count < 3 { return }
                        if vesPin.length == 0 {
                            player.name = name
                            DatabaseManager.shared.createNewRoom(with: player, completion: { pin in
                                vesPin = pin
                                keyboardShowing = false
                                player.name = name
                                buttonPressed = true
                            })
                        } else {
                            DatabaseManager.shared.playerExists(in: vesPin, with: name, completion: { exists in
                                if exists {
                                    // Player with that name already exists
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                        withAnimation(.default) {
                                            self.pinAttempts += 1
                                            self.name = ""
                                        }
                                    }
                                } else {
                                    // Proceed to room view
                                    player.name = name
                                    DatabaseManager.shared.addToRoom(with: player, to: vesPin.uppercased(), completion: {})
                                    keyboardShowing = false
                                    player.name = name
                                    buttonPressed = true
                                }
                            })
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(name.count < 3 ? 0.75 : 1))
                            .frame(maxHeight: 60 + 11.2)
                            .overlay(
                                HStack {
                                    Spacer()
                                    Image(uiImage: #imageLiteral(resourceName: "waving-hand-emoji"))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                    Text("ENTER")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .selfSizeMaskOrColor(blueGradientText, true)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            )
                    })
                    .offset(x: showButton ? 0 : screenWidth())
                    .onChange(of: name) { _ in
                        withAnimation(.default) {
                            if name.count > 0 {
                                showButton = true
                            } else {
                                showButton = false
                            }
                        }
                    }
                    
                }
                .isDetailLink(false)
                .disabled(name.count < 3 ? true : false)
                
                Spacer()
                
            }
            .padding(.top, 30)
            .padding(.horizontal, 25)
        }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            keyboardShowing = true
        }
        .onDisappear {
            keyboardShowing = false
        }
    }
}

struct NamePickView_Previews: PreviewProvider {
    static var previews: some View {
        NamePickView(navIsActive: .constant(true), vesPin: .constant("KODAS"))
    }
}
