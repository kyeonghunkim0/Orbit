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

