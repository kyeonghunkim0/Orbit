//
//  TransactionType.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import Foundation

enum TransactionType: String, CaseIterable, Codable {
    case income = "수입"
    case expense = "지출"
}
