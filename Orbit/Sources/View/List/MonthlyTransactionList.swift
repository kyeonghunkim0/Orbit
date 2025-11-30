//
//  MonthlyTransactionList.swift
//  Orbit
//
//  Created by 김경훈 on 11/25/25.
//

import SwiftUI
import SwiftData

struct MonthlyTransactionList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    
    init(month: Date) {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        _transactions = Query(filter: #Predicate<Transaction> { transaction in
            transaction.date >= startOfMonth && transaction.date < endOfMonth
        }, sort: \Transaction.date, order: .reverse)
    }
    
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        if transactions.isEmpty {
            VStack {
                Spacer()
                Text("내역이 없습니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(transactions) { transaction in
                    Button {
                        selectedTransaction = transaction
                    } label: {
                        TransactionDetailView(transaction: transaction)
                    }
                }
                .onDelete(perform: deleteTransactions)
            }
            .listStyle(.plain)
            .sheet(item: $selectedTransaction) { transaction in
                EditTransactionView(transaction: transaction)
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(transactions[index])
            }
        }
    }
}

#Preview {
    MonthlyTransactionList(month: Date())
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
