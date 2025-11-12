//
//  AddTransactionView.swift
//  Orbit
//
//  Created by 김경훈 on 11/8/25.
//

// Orbit/View/Home/AddTransactionView.swift
import SwiftUI

struct AddTransactionView: View {
    
    @EnvironmentObject var calendarModel: CalendarViewModel
    
    @Environment(\.dismiss) var dismiss
    
    // Form 입력을 위한 @State 변수
    @State private var selectedType: TransactionType = .expense
    @State private var amount: Double = 0
    @State private var memo: String = ""
    
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: Category = Category.sampleCategories[0]
    
    var filteredCategory: [Category] {
        Category.sampleCategories.filter { $0.type == selectedType }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Picker("구분",
                       selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("카테고리",
                       selection: $selectedCategory) {
                    ForEach(filteredCategory) { category in
                        Text(category.name).tag(category)
                    }
                }
                
                TextField("금액", value: $amount,
                          format: .currency(code: "KRW"))
                    .keyboardType(.decimalPad)
                
                DatePicker("날짜",
                           selection: $selectedDate,
                           displayedComponents: .date)
                
                TextField("메모", text: $memo)
            }
            .navigationTitle("내역 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 취소 버튼
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                // 저장 버튼
                ToolbarItem(placement: .confirmationAction) {
                    Button("확인") {
                        saveTransaction()
                        dismiss()
                    }
                }
            }
            // 수입/지출 타입이 변경되면, 카테고리 선택을 필터링된 목록의 첫 번째 항목으로 리셋
            .onChange(of: selectedType) {
                if let firstCateogry = filteredCategory.first {
                    selectedCategory = firstCateogry
                }
            }
        }
    }
    
    /// 입력된 정보를 새로운 Transaction 객체를 생성하고 ViewModel에 추가
    func saveTransaction() {
        let finalAmount = selectedType == .expense ? -abs(amount) : abs(amount)
        
        let newTransaction = Transaction(
            date: selectedDate,
            amount: finalAmount,
            type: selectedType,
            category: selectedCategory,
            memo: memo
        )
        
        calendarModel.allTransactions.append(newTransaction)
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(CalendarViewModel())
}
