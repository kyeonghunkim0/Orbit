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
        CalendarView(calendarModel: calendarModel)
    }
}

#Preview {
    HomeView()
        .environmentObject(CalendarViewModel())
}
