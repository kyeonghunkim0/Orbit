import SwiftUI
import SwiftData

@main
struct OrbitApp: App {
    @StateObject private var calendarModel = CalendarViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(calendarModel)
        }
        .modelContainer(for: [Transaction.self, Category.self])
    }
}

