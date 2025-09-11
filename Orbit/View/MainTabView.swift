//
//  MainTabView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI

struct MainTabView: View {
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
    }
}

#Preview {
    MainTabView()
}
