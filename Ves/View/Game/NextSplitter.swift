//
//  NextSplitter.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-06.
//

import SwiftUI

struct NextSplitter: View {
    var body: some View {
        HStack {
            Line()
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                .frame(height: 1)
            Text(" NEXT ")
                .font(.system(size: 15, weight: .black, design: .rounded))
            Line()
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                .frame(height: 1)
        }
        .opacity(0.1)
        .foregroundColor(Color(hex: "333333"))
        .padding(.vertical, 30)
    }
}

