//
//  DailyTransactionListView.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import SwiftUI

struct DailyTransactionListView: View {
    
    @ObservedObject var viewModel: CalendarViewModel
    
    /// 선택된 날짜
    let selectedDate: Date
    
    /// 선택된 날짜의 거래내역
    var dailyTransactions: [Transaction] {
        viewModel.transactions(for: selectedDate)
    }
    
    /// 날짜를 "10월 11일 (수)" 로 형태로 표시하기 위한 Formatter
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 날짜와 총 합계 표시
            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(.title2)
                    .fontWeight(.bold)
                // 해당 날짜의 총 지출/수입 합계 표시
                Text("총 지출: -50,000원")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding([.horizontal, .top])
            
            // 거래 내역이 있을 경우에만 List 표시
            if !dailyTransactions.isEmpty {
                List {
                    // 필터링된 거래 내역을 반복하여 표시
                    ForEach(dailyTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionDetailView(transaction: transaction)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    DailyTransactionListView(viewModel: CalendarViewModel(), selectedDate: Date())
}
