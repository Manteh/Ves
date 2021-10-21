//
//  RoomPlayerCell.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-12.
//

import SwiftUI
import Firebase

struct RoomPlayerCell: View {
    @Binding var player: DataSnapshot
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.white)
            .frame(height: 60 + 11.2)
            .overlay(
                ZStack {
                    Text(player.key)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "333333"))
                    
                    if player.childSnapshot(forPath: "leader").value  as! Bool == true {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color.yellow)
                            .offset(x: 60, y: -15)
                    }
                }
            )
    }
}
