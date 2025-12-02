//
//  TabBarView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI
import SwiftData

struct TabBarView: View {
    
    @EnvironmentObject var calendarModel: CalendarViewModel
    @Query private var transactions: [Transaction]
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        TabView {
            Tab("홈",
                systemImage: "house") {
                HomeView()
            }
            
            Tab("내역",
                systemImage: "list.bullet.rectangle.fill") {
                TransactionsView()
            }
            
            Tab("통계",
                systemImage: "chart.bar.fill") {
                StatisticsView()
            }
            
            Tab("설정",
                systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: transactions) { _, _ in
            calculateAndSendSummary()
        }
        .onAppear {
            calculateAndSendSummary()
        }
    }
    
    private func calculateAndSendSummary() {
        let calendar = Calendar.current
        let now = Date()
        
        // Today
        let todayStart = calendar.startOfDay(for: now)
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        
        // This Week
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
        
        // This Month
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        // This Year
        let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
        let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart)!
        
        var todayExpense: Double = 0
        var todayIncome: Double = 0
        var weekExpense: Double = 0
        var weekIncome: Double = 0
        var monthExpense: Double = 0
        var monthIncome: Double = 0
        var yearExpense: Double = 0
        var yearIncome: Double = 0
        
        for transaction in transactions {
            let date = transaction.date
            let amount = transaction.amount
            let isExpense = transaction.type == .expense
            
            // Today
            if date >= todayStart && date < todayEnd {
                if isExpense { todayExpense += amount } else { todayIncome += amount }
            }
            
            // Week
            if date >= weekStart && date < weekEnd {
                if isExpense { weekExpense += amount } else { weekIncome += amount }
            }
            
            // Month
            if date >= monthStart && date < monthEnd {
                if isExpense { monthExpense += amount } else { monthIncome += amount }
            }
            
            // Year
            if date >= yearStart && date < yearEnd {
                if isExpense { yearExpense += amount } else { yearIncome += amount }
            }
        }
        
        let summary = TransactionSummary(
            todayExpense: todayExpense,
            todayIncome: todayIncome,
            weekExpense: weekExpense,
            weekIncome: weekIncome,
            monthExpense: monthExpense,
            monthIncome: monthIncome,
            yearExpense: yearExpense,
            yearIncome: yearIncome
        )
        
        ConnectivityManager.shared.sendSummary(summary)
    }
}

#Preview {
    TabBarView()
        .environmentObject(CalendarViewModel())
}
