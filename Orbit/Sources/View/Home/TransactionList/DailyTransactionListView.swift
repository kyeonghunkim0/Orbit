//
//  DailyTransactionListView.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import SwiftUI
import SwiftData

struct DailyTransactionListView: View {
    
    @ObservedObject var viewModel: CalendarViewModel
    
    /// 선택된 날짜
    let selectedDate: Date
    
    /// 전체 거래 내역 (부모 뷰로부터 전달받음)
    let transactions: [Transaction]
    
    /// 선택된 날짜의 거래내역
    var dailyTransactions: [Transaction] {
        transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, inSameDayAs: selectedDate)
        }
    }
    
    /// 총 지출 문자열 값으로 변환
    /// - Returns: 소수점이나 콤마가 포함된 총 지출 문자열
    private func formattedTotalAmount() -> String {
        let totalAmount = viewModel.calculateTotalAmount(from: dailyTransactions)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // 쉼표 스타일
        formatter.locale = Locale(identifier: "ko_KR") // 한국 로케일
        
        // 소수점 이하가 모두 0이면 소수점 제거 (필수 설정)
        formatter.minimumFractionDigits = 0
        // 소수점 이하 최대 두 자리까지만 표시
        formatter.maximumFractionDigits = 2
        
        // 금액을 포맷합니다. Double을 NSNumber로 변환하여 사용합니다.
        let amountString = formatter.string(from: NSNumber(value: totalAmount)) ?? "0"
        
        // 금액 부호 결정
        let prefix = totalAmount > 0 ? "+" : ""
        
        return prefix + amountString + "원"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 거래 내역이 있을 경우에만 List 표시
            if !dailyTransactions.isEmpty {
                // 날짜와 총 합계 표시
                VStack(alignment: .leading, spacing: 4) {
                    // 해당 날짜의 총 지출/수입 합계 표시
                    Text("총 지출: \(formattedTotalAmount())")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding([.horizontal, .top])
                List {
                    // 필터링된 거래 내역을 반복하여 표시
                    ForEach(dailyTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionDetailView(transaction: transaction)
                    }
                }
                .listStyle(.plain)
            } else {
                // 내역이 없을 때 표시할 뷰
                VStack {
                    Spacer()
                    Text("내역이 없습니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    DailyTransactionListView(viewModel: CalendarViewModel(), selectedDate: Date(), transactions: Transaction.sampleTransactions)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
