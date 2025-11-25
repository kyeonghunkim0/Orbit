import SwiftUI
import SwiftData

@main
struct OrbitApp: App {
    @StateObject private var calendarModel = CalendarViewModel()
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Transaction.self, Category.self)
            
            // Check if categories exist
            let context = container.mainContext
            let descriptor = FetchDescriptor<Category>()
            let existingCount = try context.fetchCount(descriptor)
            
            if existingCount == 0 {
                // Add default categories
                for category in Category.defaultCategories {
                    context.insert(category)
                }
            }
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(calendarModel)
        }
        .modelContainer(container)
    }
}

