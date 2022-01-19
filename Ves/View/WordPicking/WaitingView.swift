//
//  WaitingView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-10-19.
//

import SwiftUI
import Lottie
import FirebaseDatabase

struct WaitingView: View {
    
    @State private var isPaused: Bool = false
    @Binding var players: [DataSnapshot]
    @Binding var vesPin: String
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F6")
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 50) {
                    
                    LottieView(filename: "thinking", isPaused: isPaused)
                        .frame(width: .infinity)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("WAITING FOR")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "333333").opacity(0.1))
                    
                    VStack(spacing: 20) {
                        ForEach(self.playersWithNoWords(players: players), id: \.key) { p in
                            RoundedRectangle(cornerRadius: 5)
                                .fill(orangeGradientLeftRight)
                                .frame(height: 80 + 11.2)
                                .overlay(
                                    Text(p.childSnapshot(forPath: "wordFrom").value as! String)
                                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
            }
        }
        .preferredColorScheme(.light)
    }
    
    func playersWithNoWords(players: [DataSnapshot]) -> [DataSnapshot]{
        return players.filter { $0.childSnapshot(forPath: "word").value as! String == "" }
    }
}

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    let filename: String
    let animationView = AnimationView()
    let isPaused: Bool

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animation = Animation.named(filename)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if isPaused {
            context.coordinator.parent.animationView.pause()
        } else {
            context.coordinator.parent.animationView.play()

        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: LottieView

        init(_ parent: LottieView) {
            self.parent = parent
        }
    }
}
