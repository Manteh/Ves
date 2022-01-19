//
//  RevealSheetView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-12-07.
//

import SwiftUI

struct RevealSheetView: View {
    
    @Binding var showSheet: Bool
    let onReveal: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 50) {
                VStack(spacing: 5) {
                    Text("ARE YOU SURE YOU WANT TO")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.init(hex: "333333").opacity(0.25))
                    Text("REVEAL YOUR WORD?")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.init(hex: "333333"))
                }
                
                VStack(spacing: 20) {
                    RevealSheetButtonView(
                        imageName: "eyes",
                        label: "LETS DO IT!",
                        filled: true,
                        onButtonClick: {
                            print("Show Word Reveal screen")
                            onReveal()
                        }
                    )
                    
                    RevealSheetButtonView(
                        imageName: "nope",
                        label: "NOPE",
                        filled: false,
                        onButtonClick: {
                            print("Cancel reveal")
                            self.showSheet = false
                        }
                    )
                }
                .padding(.horizontal, 20)
            }
            
        }
    }
}

struct RevealSheetView_Previews: PreviewProvider {
    static var previews: some View {
        RevealSheetView(showSheet: .constant(true), onReveal: {})
    }
}
