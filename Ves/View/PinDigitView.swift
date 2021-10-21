//
//  PinDigitView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-19.
//

import SwiftUI

struct PinDigitView: View {
    var index: Int
    @Binding var currentIndex: Int
    @Binding var digitValue: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .frame(width: getFrameWidth(), height: getFrameWidth())
            .foregroundColor(.white.opacity(isCurrentDigit() ? 1 : 0.1))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
            .overlay(
                Text(isCurrentDigit() ? "_" : digitValue[index].uppercased())
                    .font(.system(size: isCurrentDigit() ? 40 : 30, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .selfSizeMaskOrColor(orangeGradientText, isCurrentDigit())
            )
    }
    
    func getFrameWidth() -> CGFloat {
            if currentIndex >= 5 {
                return 62.8
            }
            return isCurrentDigit() ? 60 + 11.2 : 60
    }
    
    func isCurrentDigit() -> Bool {
        return index == currentIndex
    }
}

struct PinDigitView_Previews: PreviewProvider {
    static var previews: some View {
        VesPinView(navIsActive: .constant(true))
    }
}
