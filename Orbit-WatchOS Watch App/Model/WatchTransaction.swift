//
//  WatchTransaction.swift
//  Orbit-WatchOS Watch App
//
//  Created by Orbit Agent on 11/30/25.
//

import Foundation

struct WatchTransaction: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var type: String // "수입" or "지출"
    var memo: String
    var date: Date
}
