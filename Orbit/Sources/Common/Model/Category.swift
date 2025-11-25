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
    
    init(name: String, iconName: String, type: TransactionType) {
        self.name = name
        self.iconName = iconName
        self.type = type
    }
}

// 예시 카테고리
extension Category {
    static let defaultCategories: [Category] = [
        Category(name: "식비", iconName: "fork.knife", type: .expense),
        Category(name: "교통", iconName: "car.fill", type: .expense),
        Category(name: "월급", iconName: "wonsign.circle.fill", type: .income),
        Category(name: "기타", iconName: "ellipsis.circle.fill", type: .expense)
    ]
}
