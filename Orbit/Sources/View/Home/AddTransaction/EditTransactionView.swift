//
//  EditTransactionView.swift
//  Orbit
//
//  Created by Orbit on 11/30/25.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Query var categories: [Category]
    
    @Bindable var transaction: Transaction
    
    @State private var selectedType: TransactionType
    @State private var amount: Double
    @State private var memo: String
    @State private var selectedDate: Date
    @State private var selectedCategory: Category?
    
    init(transaction: Transaction) {
        self.transaction = transaction
        _selectedType = State(initialValue: transaction.type)
        _amount = State(initialValue: abs(transaction.amount))
        _memo = State(initialValue: transaction.memo)
        _selectedDate = State(initialValue: transaction.date)
        _selectedCategory = State(initialValue: transaction.category)
    }
    
    var filteredCategory: [Category] {
        categories.filter { $0.type == selectedType }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Picker("구분", selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                if !filteredCategory.isEmpty {
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(filteredCategory) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundStyle(Color(hex: category.color) ?? .primary)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                } else {
                    Text("카테고리가 없습니다.")
                }
                
                TextField("금액", value: $amount, format: .currency(code: "KRW"))
                    .keyboardType(.decimalPad)
                
                DatePicker("날짜", selection: $selectedDate, displayedComponents: .date)
                
                TextField("메모", text: $memo)
            }
            .navigationTitle("내역 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        updateTransaction()
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedType) {
                if let firstCategory = filteredCategory.first {
                    selectedCategory = firstCategory
                } else {
                    selectedCategory = nil
                }
            }
        }
    }
    
    func updateTransaction() {
        let finalAmount = selectedType == .expense ? -abs(amount) : abs(amount)
        
        transaction.type = selectedType
        transaction.amount = finalAmount
        transaction.memo = memo
        transaction.date = selectedDate
        transaction.category = selectedCategory
    }
}
