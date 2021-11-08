//
//  PinFieldView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-08.
//

import SwiftUI
import AudioToolbox

struct PinFieldView: View {
    
    @State var pinLength = 5
    @Binding var vesPin: String
    @Binding var enableTyping: Bool?
    @Binding var buttonVisible: Bool
    @Binding var currentPinIndex: Int
    @Binding var typeCount: Int
    @Binding var pinAttempts: Int
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach((0...4), id: \.self) {
                PinDigitView(index: $0, currentIndex: $currentPinIndex, digitValue: $vesPin)
            }
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
    }
    
    func resetDigits() {
        currentPinIndex = 1
        vesPin = ""
        typeCount = 0
        enableTyping = true
        buttonVisible = false
    }
}
