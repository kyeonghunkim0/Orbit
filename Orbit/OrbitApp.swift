//
//  OrbitApp.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI

@main
struct OrbitApp: App {
    @StateObject private var calendarModel = CalendarViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(calendarModel)
        }
    }
}
