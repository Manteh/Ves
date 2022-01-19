//
//  RevealSheetButtonView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-07.
//

import SwiftUI

struct RevealSheetButtonView: View {
    
    @State var imageName: String
    @State var label: String
    @State var filled: Bool
    let onButtonClick: () -> Void
    
    var body: some View {
        Button(action: onButtonClick, label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(filled ? orangeGradientLeftRight : whiteSolid)
                .frame(maxHeight: 60 + 11.2)
                .overlay(
                    HStack(spacing: 10) {
                        Image(imageName)
                        Text(label)
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(filled ? Color.white : Color.init(hex: "333333"))
                    .padding(.horizontal, 20)
                )
        })
    }
}


struct RevealSheetButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RevealSheetButtonView(imageName: "eyes", label: "LETS DO IT!", filled: false, onButtonClick: {}).previewLayout(.sizeThatFits)
    }
}

