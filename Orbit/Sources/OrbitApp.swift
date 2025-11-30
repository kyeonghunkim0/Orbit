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

