//
//  CreateVesButton.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-08.
//

import SwiftUI

struct CreateVesButton: View {
    
    @State var createRoomClicked = false
    @State var vesPin = ""
    
    var body: some View {
        Button(action: {
            vesPin = ""
            self.createRoomClicked.toggle()
        }, label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(orangeGradientLeftRight)
                .frame(maxHeight: 63)
                .overlay(
                    HStack {
                        Spacer()
                        Text("Create a new ")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                        + Text("VES")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                        Spacer()
                    }
                    .overlay(
                        Image(uiImage: #imageLiteral(resourceName: "party-face-emoji"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30)
                            .offset(x: -140)
                    )
                    .padding(.horizontal, 20)
                )
                .background(
                    NavigationLink(destination: NamePickView(navIsActive: $createRoomClicked, vesPin: $vesPin), isActive: $createRoomClicked) {
                        EmptyView()
                    }
                    .isDetailLink(false)
                )
        })
    }
}
