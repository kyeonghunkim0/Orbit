//
//  CaledarHeaderView.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct CalendarHeaderView: View {
    @StateObject var calendarModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Text(calendarModel.monthAndYearString)
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()

            Button(action: {
                // 이전 달로 이동
                calendarModel.moveMonth(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }

            Button(action: {
                // 다음 달로 이동
                calendarModel.moveMonth(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CalendarHeaderView(calendarModel: CalendarViewModel())
}
