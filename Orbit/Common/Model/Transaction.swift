//
//  Transaction.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import Foundation

struct Transaction: Identifiable {
    /// 고유 ID (CloudKit Record ID 또는 로컬 UUID)
    let id = UUID()
    
    /// 거래 발생 일시
    let date: Date
    
    /// 금액 (수입: 양수, 지출: 음수)
    let amount: Double
    
    /// 거래 유형 (수입/지출)
    let type: TransactionType
    
    /// 거래 카테고리 (예: 식비, 교통, 월급)
    let category: Category
    
    /// 거래 메모 또는 내용 (예: "스타벅스", "GS25")
    let memo: String
    
    //TODO: 나중에 CloudKit 작업 시 추가
    /// CloudKit 연동 시 필요한 Record Name 필드
    // var recordName: String?
}


extension Transaction {
    /// Dummy Data
    static let sampleTransactions: [Transaction] = [
        .init(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, amount: -15000, type: .expense, category: .sampleCategories[0], memo: "저녁 식사"),
        .init(date: Date(), amount: -4500, type: .expense, category: .sampleCategories[1], memo: "지하철"),
        .init(date: Date(), amount: -8000, type: .expense, category: .sampleCategories[0], memo: "점심 커피"),
        .init(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, amount: 2500000, type: .income, category: .sampleCategories[2], memo: "이달의 월급")
    ]
}
