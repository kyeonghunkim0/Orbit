//
//  Category.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import Foundation
import SwiftData

@Model
final class Category {
    /// 카테고리명
    var name: String
    /// 아이콘
    var iconName: String
    /// 이 카테고리가 수입인지 지출인지 구분
    var type: TransactionType
    /// 카테고리 색상 (Hex Code)
    var color: String = "#A0A0A0"
    
    init(name: String, iconName: String, type: TransactionType, color: String = "#A0A0A0") {
        self.name = name
        self.iconName = iconName
        self.type = type
        self.color = color
    }
}

// 예시 카테고리
extension Category {
    static let defaultCategories: [Category] = [
        // 지출
        Category(name: "식비", iconName: "fork.knife", type: .expense, color: "#FF5733"), // Red-Orange
        Category(name: "교통", iconName: "car.fill", type: .expense, color: "#33FF57"), // Green
        Category(name: "쇼핑", iconName: "cart.fill", type: .expense, color: "#FF33A8"), // Pink
        Category(name: "카페", iconName: "cup.and.saucer.fill", type: .expense, color: "#A833FF"), // Purple
        Category(name: "편의점", iconName: "basket.fill", type: .expense, color: "#33FFF5"), // Cyan
        Category(name: "의료", iconName: "pills.fill", type: .expense, color: "#FF3333"), // Red
        Category(name: "주거", iconName: "house.fill", type: .expense, color: "#FF8C33"), // Orange
        
        // 수입
        Category(name: "월급", iconName: "wonsign.circle.fill", type: .income, color: "#3357FF"), // Blue
        Category(name: "용돈", iconName: "envelope.fill", type: .income, color: "#33A8FF"), // Light Blue
        Category(name: "부수입", iconName: "banknote.fill", type: .income, color: "#33FF8C"), // Light Green
        Category(name: "금융수입", iconName: "chart.line.uptrend.xyaxis", type: .income, color: "#FFD700"), // Gold
        
        // 기타
        Category(name: "기타", iconName: "ellipsis.circle.fill", type: .expense, color: "#A0A0A0") // Gray
    ]
}
