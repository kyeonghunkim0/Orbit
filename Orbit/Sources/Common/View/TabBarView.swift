//
//  TabBarView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI

struct TabBarView: View {
    
    @EnvironmentObject var calendarModel: CalendarViewModel
    
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
    }
}

#Preview {
    TabBarView()
        .environmentObject(CalendarViewModel())
}
