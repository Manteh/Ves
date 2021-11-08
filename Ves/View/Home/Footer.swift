//
//  Footer.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-08.
//

import SwiftUI

struct Footer: View {
    var body: some View {
        HStack {
            VStack {
                Text("By continuing you agree to our ")
                HStack(spacing: 5) {
                    Link(destination: URL(string: "https://www.apple.com")!, label: {
                        Text("Terms")
                            .fontWeight(.bold)
                    })
                        .padding(0)
                    Text("and")
                    Link(destination: URL(string: "https://www.apple.com")!, label: {
                        Text("Conditions")
                            .fontWeight(.bold)
                    })
                }
            }
            .font(.system(size: 15, weight: .light, design: .rounded))
            .foregroundColor(Color(hex: "FFFFFF").opacity(0.5))
            .multilineTextAlignment(.center)
        }
    }
}
