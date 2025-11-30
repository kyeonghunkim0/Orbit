//
//  StatisticsViewModel.swift
//  Orbit
//
//  Created by Orbit on 11/30/25.
//

import Foundation
import SwiftData
import SwiftUI

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case week = "주간"
    case month = "월간"
    case year = "연간"
    
    var id: String { self.rawValue }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let type: TransactionType
}

struct CategoryStatistics: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
    let percentage: Double
}

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var selectedPeriod: StatisticsPeriod = .month
    @Published var selectedType: TransactionType = .expense
    
    @Published var chartData: [ChartDataPoint] = []
    @Published var categoryStatistics: [CategoryStatistics] = []
    @Published var totalAmount: Double = 0
    
    private var transactions: [Transaction] = []
    
    func updateData(with transactions: [Transaction]) {
        self.transactions = transactions
        filterAndAggregateData()
    }
    
    func filterAndAggregateData() {
        let calendar = Calendar.current
        let now = Date()
        
        var filteredTransactions: [Transaction] = []
        
        // 1. Filter by Period
        switch selectedPeriod {
        case .week:
            // Last 7 days
            if let weekAgo = calendar.date(byAdding: .day, value: -6, to: now) {
                let startOfDay = calendar.startOfDay(for: weekAgo)
                filteredTransactions = transactions.filter { $0.date >= startOfDay && $0.date <= now }
            }
        case .month:
            // Last 6 months
            if let sixMonthsAgo = calendar.date(byAdding: .month, value: -5, to: now) {
                let components = calendar.dateComponents([.year, .month], from: sixMonthsAgo)
                if let startOfMonth = calendar.date(from: components) {
                    filteredTransactions = transactions.filter { $0.date >= startOfMonth && $0.date <= now }
                }
            }
        case .year:
            // Last 5 years
            if let fiveYearsAgo = calendar.date(byAdding: .year, value: -4, to: now) {
                let components = calendar.dateComponents([.year], from: fiveYearsAgo)
                if let startOfYear = calendar.date(from: components) {
                    filteredTransactions = transactions.filter { $0.date >= startOfYear && $0.date <= now }
                }
            }
        }
        
        // 2. Filter by Type (Income/Expense)
        filteredTransactions = filteredTransactions.filter { $0.type == selectedType }
        
        // 3. Calculate Total
        totalAmount = filteredTransactions.reduce(0) { $0 + abs($1.amount) }
        
        // 4. Aggregate for Chart (Time-based)
        var timeAggregatedData: [Date: Double] = [:]
        for transaction in filteredTransactions {
            let dateKey: Date
            switch selectedPeriod {
            case .week:
                let components = calendar.dateComponents([.year, .month, .day], from: transaction.date)
                dateKey = calendar.date(from: components) ?? transaction.date
            case .month:
                let components = calendar.dateComponents([.year, .month], from: transaction.date)
                dateKey = calendar.date(from: components) ?? transaction.date
            case .year:
                let components = calendar.dateComponents([.year], from: transaction.date)
                dateKey = calendar.date(from: components) ?? transaction.date
            }
            timeAggregatedData[dateKey, default: 0] += abs(transaction.amount)
        }
        
        chartData = timeAggregatedData.map { ChartDataPoint(date: $0.key, amount: $0.value, type: selectedType) }
            .sorted { $0.date < $1.date }
            
        // 5. Aggregate by Category
        var categoryMap: [Category: Double] = [:]
        for transaction in filteredTransactions {
            if let category = transaction.category {
                categoryMap[category, default: 0] += abs(transaction.amount)
            }
        }
        
        categoryStatistics = categoryMap.map { category, amount in
            CategoryStatistics(category: category, amount: amount, percentage: totalAmount > 0 ? amount / totalAmount : 0)
        }.sorted { $0.amount > $1.amount }
    }
}
