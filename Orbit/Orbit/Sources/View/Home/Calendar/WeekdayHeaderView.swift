//
//  WeekdayHeaderView.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct WeekdayHeaderView: View {
    
    private let weekdays: [String] = [
        "일", "월", "화", "수", "목", "금", "토"
    ]
    
    var body: some View {
        HStack {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    // 일요일 Text 색상 Red
                    .foregroundStyle(day == "일" ? .red : .black)
            }
        }
    }
}

#Preview {
    WeekdayHeaderView()
}
