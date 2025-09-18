//
//  CalendarView.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct CalendarView: View {
    
    @ObservedObject var calenderModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            WeekdayHeaderView()
            CalendarGridView(viewModel: calenderModel)
        }
    }
}

#Preview {
    CalendarView(calenderModel: CalendarViewModel())
}
