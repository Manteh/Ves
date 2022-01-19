//
//  GameSummaryView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-16.
//

import SwiftUI
import Firebase

struct GameSummaryView: View {
    
    @Binding var finishedPlayers: [DataSnapshot]
    let onLeaveClick: () -> Void
    
    var body: some View {
        ZStack {
            Color.init(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
            
                // Header
                VStack(spacing: 20) {
                    orangeGradientTopBottom
                        .frame(height: 30)
                        .mask(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                        )
                    orangeGradientTopBottom
                        .frame(height: 30)
                        .mask(
                            Text("Game Summary")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .kerning(2)
                        )
                }
                
                Spacer()
                
                ForEach($finishedPlayers, id: \.self) { p in
                    GameSummaryCard(
                        pos: ((finishedPlayers.index(of: p.wrappedValue)! as! Int) + 1),
                        name: p.wrappedValue.key,
                        word: p.wrappedValue.childSnapshot(forPath: "word").value as! String,
                        turns: p.wrappedValue.childSnapshot(forPath: "turns").value as! Int
                    )
                }
                
                Spacer()
                
                LeaveRoomButton {
                    onLeaveClick()
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 25)
        }
    }
}

struct GameSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        GameSummaryView(finishedPlayers: .constant([DataSnapshot()]), onLeaveClick: {})
    }
}
