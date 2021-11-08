//
//  JoinVesButton.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-08.
//

import SwiftUI

struct JoinVesButton: View {
    
    @State var navIsActive = false
    
    var body: some View {
        Button(action: {}, label: {
            NavigationLink(destination: VesPinView(navIsActive: self.$navIsActive), isActive: self.$navIsActive) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(maxHeight: 63)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("Join with ")
                                .foregroundColor(Color(hex: "333333"))
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                            + Text("VES Pin")
                                .foregroundColor(Color(hex: "333333"))
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                            Spacer()
                        }
                        .overlay(
                            Image(uiImage: #imageLiteral(resourceName: "waving-hand-emoji"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30)
                                .offset(x: 140)
                        )
                        .padding(.horizontal, 20)
                    )
            }
            .isDetailLink(false)
        })
    }
}

