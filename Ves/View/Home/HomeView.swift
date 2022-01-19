//
//  HomeView.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import SwiftUI

struct HomeView: View {
    
    @State var navIsActive: Bool = false
    @State private var showGameRules = false
    @State var createRoomClicked = false
    @State var vesPin = ""
        
    var body: some View {
        NavigationView {
            ZStack {
                Color.init(hex: "F2F2F6")
                
                ZStack {
                    PlayerView()
                        .frame(width: screenWidth())
                    Color.black.opacity(0.5)
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    GameRules()
                    
                    Spacer()
                    
                    Logo()
                    
                    Spacer()

                    VStack(spacing: 20) {
                        
                        CreateVesButton()
                        JoinVesButton()
                        
                    }
                    
                }
                .padding(.horizontal, 25)
                .padding(.top, safeTop() + 20)
                .padding(.bottom, safeBottom() + 20)
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .preferredColorScheme(.light)
            .onAppear {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

func screenWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

func safeBottom() -> CGFloat {
    if #available(iOS 13.0, *) {
        let window = UIApplication.shared.windows.first
        let bottomPadding = window!.safeAreaInsets.bottom
        return bottomPadding
    }
    return 0
}

func safeTop() -> CGFloat {
    if #available(iOS 13.0, *) {
        let window = UIApplication.shared.windows.first
        let topPadding = window!.safeAreaInsets.top
        return topPadding
    }
    return 0
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
