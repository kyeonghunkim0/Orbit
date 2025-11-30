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
    
    var groupedTransactions: [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
    
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
                ForEach(groupedTransactions, id: \.0) { date, transactions in
                    Section(header: Text(dateFormatter.string(from: date))) {
                        ForEach(transactions) { transaction in
                            TransactionDetailView(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTransaction = transaction
                                }
                        }
                        .onDelete { offsets in
                            deleteTransactions(offsets: offsets, in: transactions)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .sheet(item: $selectedTransaction) { transaction in
                EditTransactionView(transaction: transaction)
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet, in transactions: [Transaction]) {
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
