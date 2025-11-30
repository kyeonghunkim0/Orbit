//
//  Orbit_WatchOSApp.swift
//  Orbit-WatchOS Watch App
//
//  Created by 김경훈 on 11/30/25.
//  Copyright © 2025 xoul.kimkhuna. All rights reserved.
//

import SwiftUI

@main
struct Orbit_WatchOS_Watch_AppApp: App {
    @StateObject private var connectivityManager = ConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityManager)
        }
    }
}
