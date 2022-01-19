//
//  RoomHeader.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-11-06.
//

import SwiftUI
import FirebaseDatabase

struct RoomHeader: View {
    @State var title: String
    @Binding var players: [DataSnapshot]
    @Binding var localPlayer: Player
    let onMarkClick: () -> Void
    
    var body: some View {
        // Header
        VStack(alignment: .leading, spacing: 5) {
            Text("\(players.count) PLAYERS")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .selfSizeMaskOrColor(orangeGradientText, true)
            HStack {
                Text(title)
                    .font(.system(size: 35, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "333333"))
                Spacer()
                Button(action: {
                    DispatchQueue.main.async {
                        onMarkClick()
                    }
                }, label: {
                    Image(systemName: "xmark.square.fill")
                        .resizable()
                        .foregroundColor(.black.opacity(0.1))
                        .opacity(markVisible() ? 1 : 0)
                        .disabled(!markVisible())
                })
                .frame(width: 25, height: 25)
            }
        }
    }
    
    func markVisible() -> Bool {
        return players.filter { $0.key == localPlayer.name }.count != 0
    }
}
