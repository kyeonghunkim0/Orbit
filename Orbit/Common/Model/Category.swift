//
//  Category.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import Foundation

struct Category: Identifiable, Hashable {
    let id = UUID()
    /// 카테고리명
    let name: String
    /// 아이콘
    let iconName: String
    /// 이 카테고리가 수입인지 지출인지 구분
    let type: TransactionType
}

// 예시 카테고리
extension Category {
    static let sampleCategories: [Category] = [
        .init(name: "식비", iconName: "fork.knife", type: .expense),
        .init(name: "교통", iconName: "car.fill", type: .expense),
        .init(name: "월급", iconName: "wonsign.circle.fill", type: .income),
        .init(name: "기타", iconName: "ellipsis.circle.fill", type: .expense)
    ]
}
