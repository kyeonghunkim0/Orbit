//
//  HomeView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var calendarModel: CalendarViewModel
    
    var body: some View {
        NavigationView {
            // VStack으로 감싸서 캘린더와 거래 목록을 세로로 배치
            VStack {
                CalendarView(calendarModel: calendarModel)
                    .padding()
                
                // 선택된 날짜가 있을 때만 DailyTransactionListView 표시
                if let selectedDate = calendarModel.selectedDate{
                    DailyTransactionListView(viewModel: calendarModel, selectedDate: selectedDate)
                } else {
                    Spacer()
                }
            }
            .padding()
            .navigationBarItems(trailing: TranscationAddButton())
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CalendarViewModel())
}
