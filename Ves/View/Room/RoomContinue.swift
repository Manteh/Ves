//
//  RoomContinue.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-07.
//

import SwiftUI

struct RoomContinue: View {
    
    let onButtonClick: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {

            HStack {
                Text("EVERYONE READY?")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "333333"))
                    .opacity(0.1)
            }

            Button(action: onButtonClick, label: {
                RoundedRectangle(cornerRadius: 5)
                    .fill(orangeGradientLeftRight)
                    .frame(maxHeight: 60 + 11.2)
                    .overlay(
                        HStack {
                            Image(systemName: "arrow.right").opacity(0)
                            Spacer()
                            Text("CONTINUE")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    )
            })

        }
    }
}
