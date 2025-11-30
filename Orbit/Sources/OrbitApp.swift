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
    
    @StateObject private var connectivityManager = ConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(calendarModel)
                .onChange(of: connectivityManager.receivedTransaction) { _, newData in
                    guard let data = newData else { return }
                    handleReceivedTransaction(data)
                }
                .onAppear {
                    sendCategoriesToWatch()
                }
        }
        .modelContainer(container)
    }
    
    private func sendCategoriesToWatch() {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Category>()
        
        do {
            let categories = try context.fetch(descriptor)
            let watchCategories = categories.map { category in
                WatchCategory(name: category.name, type: category.type.rawValue)
            }
            connectivityManager.sendCategories(watchCategories)
            print("Sent \(watchCategories.count) categories to Watch")
        } catch {
            print("Failed to fetch categories for Watch: \(error)")
        }
    }
    
    private func handleReceivedTransaction(_ data: ReceivedTransaction) {
        let context = container.mainContext
        
        // Find category
        let categoryName = data.category
        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == categoryName }
        )
        
        do {
            let categories = try context.fetch(categoryDescriptor)
            let category = categories.first
            
            let type = TransactionType(rawValue: data.type) ?? .expense
            
            let transaction = Transaction(
                date: data.date,
                amount: data.amount,
                type: type,
                category: category,
                memo: data.memo
            )
            
            context.insert(transaction)
            print("Transaction added from Watch: \(data.memo)")
            
        } catch {
            print("Failed to save transaction from Watch: \(error)")
        }
    }
}

