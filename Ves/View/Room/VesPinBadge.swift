//
//  VesPinBadge.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-07.
//

import SwiftUI

struct VesPinBadge: View {
    
    @Binding var vesPin: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(orangeGradientLeftRight)
                .frame(height: 60 + 11.2)
                .overlay(
                    HStack {
                        Text("VES PIN")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "circles.hexagongrid.fill")
                            Text("\(vesPin)")
                        }
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                )
        }
    }
}
