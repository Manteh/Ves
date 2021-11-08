//
//  Logo.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-08.
//

import SwiftUI

struct Logo: View {
    var body: some View {
        VStack(spacing: 20) {
            orangeGradientTopBottom
                .frame(height: 50)
                .mask(
                    Label("VES", systemImage: "leaf.fill")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                )
            HStack {
                Text("IN").kerning(1) +
                Text("VES").kerning(1)
                    .fontWeight(.heavy) +
                Text("TIGATIVE PARTY GAME").kerning(1)
            }
            .font(.system(size: 15, design: .rounded))
            .foregroundColor(Color(hex: "C8C8C8"))
        }
    }
}
