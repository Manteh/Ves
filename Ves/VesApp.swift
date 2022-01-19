//
//  VesApp.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseDatabase

@main
struct VesApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var player: Player = Player(name: "Mantelis")
    @State var players: [DataSnapshot] = [DataSnapshot()]
    @State var vesPin = "TY647"
    @State var showReveal = true
    
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        print("terminating..")
    }
}
