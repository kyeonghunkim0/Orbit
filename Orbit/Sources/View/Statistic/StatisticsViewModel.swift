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
    let category: Category?
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
    
    @Published var chartStartDate: Date = Date()
    @Published var chartEndDate: Date = Date()
    @Published var focusedDate: Date = Date()
    
    private var transactions: [Transaction] = []
    
    func updateData(with transactions: [Transaction]) {
        self.transactions = transactions
        filterAndAggregateData()
    }
    
    func filterAndAggregateData() {
        generateChartData()
        updateStatistics(for: focusedDate)
    }
    
    func generateChartData() {
        let calendar = Calendar.current
        let now = Date()
        
        var filteredTransactions: [Transaction] = []
        
        // 1. Filter by Period (for Chart Range)
        switch selectedPeriod {
        case .week:
            // Last 7 days
            if let weekAgo = calendar.date(byAdding: .day, value: -6, to: now) {
                let startOfDay = calendar.startOfDay(for: weekAgo)
                filteredTransactions = transactions.filter { $0.date >= startOfDay && $0.date <= now }
                
                chartStartDate = calendar.date(byAdding: .day, value: -1, to: startOfDay) ?? startOfDay
                chartEndDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            }
        case .month:
            // Last 6 months
            if let sixMonthsAgo = calendar.date(byAdding: .month, value: -5, to: now) {
                let components = calendar.dateComponents([.year, .month], from: sixMonthsAgo)
                if let startOfMonth = calendar.date(from: components) {
                    filteredTransactions = transactions.filter { $0.date >= startOfMonth && $0.date <= now }
                    
                    chartStartDate = calendar.date(byAdding: .day, value: -15, to: startOfMonth) ?? startOfMonth
                    chartEndDate = calendar.date(byAdding: .day, value: 15, to: now) ?? now
                }
            }
        case .year:
            // Last 5 years
            if let fiveYearsAgo = calendar.date(byAdding: .year, value: -4, to: now) {
                let components = calendar.dateComponents([.year], from: fiveYearsAgo)
                if let startOfYear = calendar.date(from: components) {
                    filteredTransactions = transactions.filter { $0.date >= startOfYear && $0.date <= now }
                    
                    chartStartDate = calendar.date(byAdding: .month, value: -6, to: startOfYear) ?? startOfYear
                    chartEndDate = calendar.date(byAdding: .month, value: 6, to: now) ?? now
                }
            }
        }
        
        // 2. Filter by Type (Income/Expense)
        filteredTransactions = filteredTransactions.filter { $0.type == selectedType }
        
        // 3. Aggregate for Chart (Time-based + Category)
        struct AggregationKey: Hashable {
            let date: Date
            let category: Category?
        }
        
        var aggregatedData: [AggregationKey: Double] = [:]
        
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
            
            let key = AggregationKey(date: dateKey, category: transaction.category)
            aggregatedData[key, default: 0] += abs(transaction.amount)
        }
        
        chartData = aggregatedData.map { key, value in
            ChartDataPoint(date: key.date, amount: value, type: selectedType, category: key.category)
        }.sorted { $0.date < $1.date }
    }
    
    func updateStatistics(for date: Date) {
        let calendar = Calendar.current
        var targetTransactions: [Transaction] = []
        
        // Filter transactions for the specific focused date unit
        switch selectedPeriod {
        case .week:
            // Specific Day
            let startOfDay = calendar.startOfDay(for: date)
            if let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) {
                targetTransactions = transactions.filter { $0.date >= startOfDay && $0.date < endOfDay }
            }
        case .month:
            // Specific Month
            let components = calendar.dateComponents([.year, .month], from: date)
            if let startOfMonth = calendar.date(from: components),
               let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) {
                targetTransactions = transactions.filter { $0.date >= startOfMonth && $0.date < endOfMonth }
            }
        case .year:
            // Specific Year
            let components = calendar.dateComponents([.year], from: date)
            if let startOfYear = calendar.date(from: components),
               let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) {
                targetTransactions = transactions.filter { $0.date >= startOfYear && $0.date < endOfYear }
            }
        }
        
        // Filter by Type
        targetTransactions = targetTransactions.filter { $0.type == selectedType }
        
        // Calculate Total
        totalAmount = targetTransactions.reduce(0) { $0 + abs($1.amount) }
        
        // Aggregate by Category
        var categoryMap: [Category: Double] = [:]
        for transaction in targetTransactions {
            if let category = transaction.category {
                categoryMap[category, default: 0] += abs(transaction.amount)
            }
        }
        
        categoryStatistics = categoryMap.map { category, amount in
            CategoryStatistics(category: category, amount: amount, percentage: totalAmount > 0 ? amount / totalAmount : 0)
        }.sorted { $0.amount > $1.amount }
    }
}
