//
//  LeaveRoomButton.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-09.
//

import SwiftUI

struct LeaveRoomButton: View {
    
    var onButtonClick: () -> Void
    
    var body: some View {
        Button(action: onButtonClick, label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(whiteSolid)
                .frame(maxHeight: 60 + 11.2)
                .overlay(
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.square.fill").opacity(0)
                        Spacer()
                        Text("LEAVE THE ROOM")
                        Spacer()
                        Image(systemName: "xmark.square.fill")
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.init(hex: "333333").opacity(0.5))
                    .padding(.horizontal, 20)
                )
        })
    }
}

struct LeaveRoomButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            LeaveRoomButton(onButtonClick: {}).previewLayout(.sizeThatFits)
        }
    }
}
