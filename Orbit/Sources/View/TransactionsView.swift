//
//  TransactionsView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(transactions) { transaction in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(transaction.category?.name ?? "미분류")
                                .font(.headline)
                            Text(transaction.memo)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(transaction.amount, format: .currency(code: "KRW"))
                            .foregroundColor(transaction.type == .income ? .blue : .red)
                    }
                }
            }
            .navigationTitle("전체 내역")
        }
    }
}

#Preview {
    TransactionsView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
