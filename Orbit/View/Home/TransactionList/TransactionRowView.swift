//
//  TransactionDetailView.swift
//  Orbit
//
//  Created by 김경훈 on 10/11/25.
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    
    /// 거래 유형에 따른 색상
    var amountColor: Color {
        .primary
    }
    
    private func formattedAmount() -> String {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal // 통화 기호 대신 쉼표만 사용
           formatter.locale = Locale(identifier: "ko_KR")
           
           // 절대값(abs)을 사용하여 숫자만 포맷합니다.
           let amountText = formatter.string(for: abs(transaction.amount)) ?? "0"
           
           let prefix: String
           switch transaction.type {
           case .expense:
               // 지출은 음수 부호(-) 사용
               prefix = "-"
           case .income:
               // 수입은 양수 부호(+) 또는 공백 사용. 여기서는 +를 유지합니다.
               prefix = "+"
           }
           
           return prefix + amountText + "원"
       }
    
    var body: some View {
        HStack(spacing: 15) {
            // 카테고리 아이콘
            Image(systemName: transaction.category.iconName)
                .resizable()
                .frame(width: 20, height: 20)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            // 카테고리 이름 & 메모
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(transaction.memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 금액
            Text(formattedAmount())
                .font(.subheadline)
            // 수입은 굵게, 지출은 보통 굵기
                .fontWeight(transaction.type == .income ? .bold : .medium)
                .foregroundStyle(amountColor)
        }
        .padding([.vertical, .horizontal], 10)
    }
}

#Preview {
    TransactionDetailView(transaction: Transaction.sampleTransactions[0])
}
