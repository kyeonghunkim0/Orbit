//
//  CalendarView.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 32) {
            CalendarHeaderView(calendarModel: calendarModel)
            WeekdayHeaderView()
            CalendarGridView(viewModel: calendarModel)
        }
    }
}

#Preview {
    CalendarView(calendarModel: CalendarViewModel())
}
