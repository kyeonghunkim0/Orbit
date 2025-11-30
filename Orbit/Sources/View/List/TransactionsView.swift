//
//  TransactionsView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @State private var currentMonth: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Month Selector
                HStack {
                    Button(action: {
                        changeMonth(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text(currentMonth, format: .dateTime.year().month())
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        changeMonth(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                // Transaction List
                MonthlyTransactionList(month: currentMonth)
            }
            .navigationTitle("전체 내역")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
}

#Preview {
    TransactionsView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
