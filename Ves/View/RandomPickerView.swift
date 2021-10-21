//
//  RandomPickerView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-12.
//

import SwiftUI

struct RandomPickerView: View {
    
    @State var seatColor = Color.black.opacity(0.5)
    @State var highlightColor = orangeGradientBG
    @State var seats = [
        true, false, false,
        false, false, false,
        false, false, false, false
    ]
    @State var seatSelected = 0
    @State var times = 1
    @State var blank: Bool = false
    @State var time: Double = 0.0
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    SeatView(isEmpty: false, isHighlighted: $seats[0])
                    SeatView(isEmpty: false, isHighlighted: $seats[1])
                }
                HStack(spacing: 20) {
                    SeatView(isEmpty: false, isHighlighted: $seats[9])
                    SeatView(isEmpty: true, isHighlighted: $blank)
                    SeatView(isEmpty: true, isHighlighted: $blank)
                    SeatView(isEmpty: false, isHighlighted: $seats[2])
                }
                HStack(spacing: 20) {
                    SeatView(isEmpty: false, isHighlighted: $seats[8])
                    SeatView(isEmpty: true, isHighlighted: $blank)
                    SeatView(isEmpty: true, isHighlighted: $blank)
                    SeatView(isEmpty: false, isHighlighted: $seats[3])
                }
                HStack(spacing: 20) {
                    SeatView(isEmpty: false, isHighlighted: $seats[7])
                    SeatView(isEmpty: true, isHighlighted: $blank)
                    SeatView(isEmpty: true, isHighlighted: $blank)
                    SeatView(isEmpty: false, isHighlighted: $seats[4])
                }
                HStack(spacing: 20) {
                    SeatView(isEmpty: false, isHighlighted: $seats[6])
                    SeatView(isEmpty: false, isHighlighted: $seats[5])
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                changeSeat()
            }
        }
    }
    
    func changeSeat() {
//        if seatSelected + 1 < seats.count {
//            seatSelected += 1
//        } else {
//            seatSelected = 0
//        }
//        seats[seatSelected].toggle()

        withAnimation(.spring()) {
            seatSelected = Int.random(in: 0..<seats.count)
            seats[seatSelected].toggle()
        }
    }
}

struct SeatView: View {
    
    @State var isEmpty: Bool
    @Binding var isHighlighted: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 50, height: 50)
            .foregroundColor($isHighlighted.wrappedValue ? Color.orange : Color.black.opacity(0.1))
            .opacity(isEmpty ? 0 : 1)
    }
    
}

struct RandomPickerView_Previews: PreviewProvider {
    static var previews: some View {
        RandomPickerView()
    }
}
