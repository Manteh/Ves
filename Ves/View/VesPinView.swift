//
//  VesPinView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import SwiftUI
import AudioToolbox

struct VesPinView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var navIsActive: Bool
    @State var currentPinIndex = 0
    @State var vesPin = ""
    @State var typeCount = 0
    @State var enableTyping: Bool? = false
    @State var buttonVisible: Bool = false
    @State var pinAttempts: Int = 0
    @State var isShowingDetailView = false
    @State var pinLength = 5

    var body: some View {

        ZStack {
            orangeGradientBG
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 50) {
            
                // Back to Home Button
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
                
                // View Content
                VStack(alignment: .leading, spacing: 50) {
                    
                    VStack(alignment: .leading) {
                        Text("ENTER YOUR")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                        Text("VES PIN")
                            .font(.system(size: 50, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    
                    HStack(alignment: .center, spacing: 10) {
                        PinDigitView(index: 0, currentIndex: $currentPinIndex, digitValue: $vesPin)
                        PinDigitView(index: 1, currentIndex: $currentPinIndex, digitValue: $vesPin)
                        PinDigitView(index: 2, currentIndex: $currentPinIndex, digitValue: $vesPin)
                        PinDigitView(index: 3, currentIndex: $currentPinIndex, digitValue: $vesPin)
                        PinDigitView(index: 4, currentIndex: $currentPinIndex, digitValue: $vesPin)
                    }
                    .modifier(Shake(animatableData: CGFloat(pinAttempts)))
                    .background(
                        CustomTextField(text: $vesPin,
                                        nextResponder: .constant(nil),
                                        isResponder: $enableTyping,
                                        textLimit: $pinLength,
                                        isSecured: true,
                                        keyboard: .default)
                            .onChange(of: vesPin) {char in
                                if vesPin[currentPinIndex] == " " {
                                    return
                                }
                                
                                if currentPinIndex < 5 {
                                    if vesPin.count > typeCount {
                                        currentPinIndex += 1
                                        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                                        impactMed.impactOccurred()
                                    } else {
                                        if currentPinIndex > 0 {
                                            currentPinIndex -= 1
                                        }
                                    }
                                }
                                
                                if vesPin.count >= 5 {
                                    vesPin = vesPin.uppercased()
                                    DatabaseManager.shared.roomExists(with: vesPin, completion: { exists in
                                        guard exists else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                withAnimation(.default) {
                                                    self.pinAttempts += 1
                                                }
                                                resetDigits()
                                            }
                                            return
                                        }
                                        
                                        withAnimation(.spring()) {
                                            buttonVisible = true
                                        }
                                    })
                                }
                                
                                typeCount = vesPin.count
                            }
                            .frame(width: .infinity)
                            .background(Color.red)
                            .opacity(0)
                            .disabled(currentPinIndex >= 5 ? true : false)
                            
                            
                    )
                    .frame(minHeight: 71.2)
                                                            
                    if buttonVisible {
                        
                        LoadingIndicator()
                            .background(
                                NavigationLink(destination: NamePickView(navIsActive: $navIsActive, vesPin: $vesPin), isActive: $isShowingDetailView) {
                                    EmptyView()
                                }
                                .isDetailLink(false)
                                .onAppear {
                                    print("Showing view in 1 seconds...")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        if buttonVisible {
                                            DatabaseManager.shared.roomExists(with: vesPin.uppercased(), completion: { exists in
                                                guard exists else {
                                                    print("Room not found")
                                                    return
                                                }
                                                print("Room found")
                                                self.isShowingDetailView.toggle()
                                            })
                                        }
                                    }
                                }
                            )
                    }
                        
                    
                    
                    Button(action: {}, label: {
                        HStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "questionmark.circle.fill")
                            Text("What is a ")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                            +
                            Text("VES PIN?")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                            Spacer()
                        }
                        .foregroundColor(.white)
                    })
                    
                        
                    
                    Spacer()
                }
                .offset(y: buttonVisible == true ? 0 : 50)
                
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
        }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear(perform: {
                resetView()
                withAnimation(.spring()) {
                    enableTyping = true
                }
            })
            

    }
    
    func resetView() {
        isShowingDetailView = false
        currentPinIndex = 0
        vesPin = ""
        typeCount = 0
        enableTyping = false
        buttonVisible = false
        pinAttempts = 0
    }
    
    func resetDigits() {
        currentPinIndex = 1
        vesPin = ""
        typeCount = 0
        enableTyping = true
        buttonVisible = false
    }
    
}

struct LoadingIndicator: View {
    
    @State var animate = false
    
    var body: some View {
        VStack(alignment: .center) {
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(AngularGradient(gradient: .init(colors: [.white.opacity(0), .white]), center: .center), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .frame(width: 45, height: 45)
                .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
        }
        .onAppear {
            self.animate.toggle()
        }
        .foregroundColor(.white)
        .frame(maxWidth: screenWidth())
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

func digitWidth() -> CGFloat {
    return ((screenWidth() - 60) - 40) / 5
}

struct VesPinView_Previews: PreviewProvider {
    static var previews: some View {
        VesPinView(navIsActive: .constant(true))
    }
}
