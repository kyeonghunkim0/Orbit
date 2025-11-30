//
//  HomeView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var calendarModel: CalendarViewModel
    @Query private var transactions: [Transaction]
    
    /// Sheet 표시 여부
    @State private var isShowingAddSheet = false

    
    var body: some View {
        NavigationView {
            // VStack으로 감싸서 캘린더와 거래 목록을 세로로 배치
            VStack {
                CalendarView(calendarModel: calendarModel)
                
                // 선택된 날짜가 있을 때만 DailyTransactionListView 표시
                if let selectedDate = calendarModel.selectedDate{
                    DailyTransactionListView(viewModel: calendarModel, selectedDate: selectedDate, transactions: transactions)
                } else {
                    Spacer()
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddTransactionView()
                // 시트 뷰에서도 ViewModel에 접근할 수 있도록 environmentObject를 전달
                    .environmentObject(calendarModel)
            }
            .padding()
            .toolbar {
                Button(role: .destructive, action: {
                    isShowingAddSheet.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                })
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    HomeView()
        .environmentObject(CalendarViewModel())
}
