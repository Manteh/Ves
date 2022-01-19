//
//  GameSummaryCard.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-16.
//

import SwiftUI

struct GameSummaryCard: View {
    
    @State var pos: Int
    @State var name: String
    @State var word: String
    @State var turns: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 80)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 4)
            .overlay (
                HStack(spacing: 0) {
                    Text("\(pos)")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.orange)
                        .frame(width: 80, height: 80)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(name)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333"))
                        Text(word)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color.init(hex: "333333").opacity(0.25))
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("\(turns)")
                        Image(systemName: "return")
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.orange)
                    .frame(width: 80, height: 80)
                }
            )
    }
}

struct GameSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        GameSummaryCard(pos: 1, name: "Mantas", word: "Apple", turns: 3)

    }
}
