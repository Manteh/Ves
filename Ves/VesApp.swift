//
//  VesApp.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import SwiftUI
import UIKit
import Firebase

@main
struct VesApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
