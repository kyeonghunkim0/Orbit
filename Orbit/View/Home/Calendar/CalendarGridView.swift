//
//  CalendarGridView.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let colums = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: colums, spacing: 30) {
            ForEach(viewModel.convertDateToDateValue(from: viewModel.currentMonth)) { value in
                Text("\(value.day)")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    CalendarGridView(viewModel: CalendarViewModel())
}
