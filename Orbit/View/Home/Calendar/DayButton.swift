//
//  DayButton.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct DayButton: View {
    
    let date: DateValue
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Text("\(date.day)")
                    .font(.headline)
                    .foregroundColor(date.isCurrentMonth ? .primary : .secondary)
                    .frame(width: 40, height: 40)
            }
            if date.hasTransactions {
                Circle()
                    .fill(Color.red)
                    .frame(width: 5, height: 5)
                    .padding(4)
            }
        }
    }
}

#Preview {
    let dummy = DateValue(day: 1,
                          date: Date(),
                          isCurrentMonth: true,
                          hasTransactions: true)
    DayButton(date: dummy)
}
