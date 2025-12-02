import SwiftUI
import SwiftData

@main
struct OrbitApp: App {
    @StateObject private var calendarModel = CalendarViewModel()
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Transaction.self, Category.self)
            
            // Check and add missing default categories
            let context = container.mainContext
            
            for category in Category.defaultCategories {
                let categoryName = category.name
                let descriptor = FetchDescriptor<Category>(
                    predicate: #Predicate { $0.name == categoryName }
                )
                let count = try context.fetchCount(descriptor)
                
                if count == 0 {
                    context.insert(category)
                    print("Added missing default category: \(category.name)")
                }
            }
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    @StateObject private var connectivityManager = ConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(calendarModel)
        }
        .modelContainer(container)
    }
}

