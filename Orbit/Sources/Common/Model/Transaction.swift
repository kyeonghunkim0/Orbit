//
//  Transaction.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    /// 거래 발생 일시
    var date: Date
    
    /// 금액 (수입: 양수, 지출: 음수)
    var amount: Double
    
    /// 거래 유형 (수입/지출)
    var type: TransactionType
    
    /// 거래 카테고리 (예: 식비, 교통, 월급)
    @Relationship
    var category: Category?
    
    /// 거래 메모 또는 내용 (예: "스타벅스", "GS25")
    var memo: String
    
    //TODO: 나중에 CloudKit 작업 시 추가
    /// CloudKit 연동 시 필요한 Record Name 필드
    // var recordName: String?
    
    init(date: Date, amount: Double, type: TransactionType, category: Category? = nil, memo: String) {
        self.date = date
        self.amount = amount
        self.type = type
        self.category = category
        self.memo = memo
    }
}


extension Transaction {
    /// Dummy Data
    static let sampleTransactions: [Transaction] = [
        Transaction(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, amount: -15000, type: .expense, category: Category.sampleCategories[0], memo: "저녁 식사"),
        Transaction(date: Date(), amount: -4500, type: .expense, category: Category.sampleCategories[1], memo: "지하철"),
        Transaction(date: Date(), amount: -8000, type: .expense, category: Category.sampleCategories[0], memo: "점심 커피"),
        Transaction(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, amount: 2500000, type: .income, category: Category.sampleCategories[2], memo: "이달의 월급")
    ]
}
