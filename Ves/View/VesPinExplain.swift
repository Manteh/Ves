//
//  VesPinExplain.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-24.
//

import SwiftUI

struct VesPinExplain: View {
    @Environment(\.presentationMode) var presentationMode
    
    let desc = "Ves Pin is a custom and unique code that is created when a new game room is made. Basically you, or a friend of yours, can create a room for you all. When the first player is in the lobby, that player can then share that Ves Pin with other players that wants to join. "

    var body: some View {
        ZStack {
            Color(hex: "F2F2F6").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("What is ")
                            .foregroundColor(Color(hex: "333333"))
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .kerning(2)
                        orangeGradientTopBottom
                            .frame(height: 50)
                            .mask(
                                Text("VES PIN?")
                                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                                    .kerning(2)
                            )
                    }
                    .padding(.bottom, 50)
                    
                    VStack(spacing: 50) {
                        
                        Image("vesPinExplain")
                            .resizable()
                            .scaledToFit()
                            .padding(15)
                        
                        Text(desc)
                            .foregroundColor(Color(hex: "333333").opacity(0.5))
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .lineSpacing(5)
                    }
                }
                .padding(.top, 50)
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 30)

        }
    }
    
}

struct VesPinExplain_Previews: PreviewProvider {
    static var previews: some View {
        VesPinExplain()
    }
}
