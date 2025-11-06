//
//  DayButton.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import SwiftUI

struct DayButton: View {
    
    let date: DateValue
    // MARK: 1. ViewModel 접근을 위해 EnvironmentObject 추가
    @EnvironmentObject var viewModel: CalendarViewModel
    
    // MARK: 2. 현재 날짜가 선택된 날짜인지 확인하는 계산 프로퍼티
    var isSelected: Bool {
        guard let selectedDate = viewModel.selectedDate else { return false }
        // Date+Extension의 isSameDay를 사용할 수도 있지만, Calendar.current.isDate를 사용하겠습니다.
        return Calendar.current.isDate(date.date, inSameDayAs: selectedDate)
    }
    
    // MARK: 3. View를 Button으로 변경하고 selectDate 액션 추가
    var body: some View {
        Button(action: {
            viewModel.selectDate(date: date.date)
        }) {
            ZStack(alignment: .topTrailing) {
                VStack {
                    Text("\(date.day)")
                        .font(.headline)
                        .foregroundColor(date.isCurrentMonth ? .primary : .secondary)
                        .frame(width: 40, height: 40)
                        // MARK: 4. 선택되었을 때 시각적 피드백 추가
                        .background(
                            Circle()
                                .stroke(isSelected ? .blue : .clear, lineWidth: 2) // 선택되면 파란색 테두리
                                .fill(isSelected ? Color.blue.opacity(0.1) : .clear) // 선택되면 약간의 배경색
                        )
                }
                if date.hasTransactions {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 5, height: 5)
                        .padding(4)
                }
            }
        }
        .buttonStyle(.plain) // 버튼 스타일을 기본 스타일로 유지하여 Text 색상 변경 방지
        // 선택되지 않은 달의 날짜는 탭할 수 없도록 비활성화
        .disabled(!date.isCurrentMonth)
    }
}

#Preview {
    let dummy = DateValue(day: 1,
                          date: Date(),
                          isCurrentMonth: true,
                          hasTransactions: true)
    // Preview에서도 EnvironmentObject를 제공해야 합니다.
    return DayButton(date: dummy)
        .environmentObject(CalendarViewModel())
}

#Preview {
    let dummy = DateValue(day: 1,
                          date: Date(),
                          isCurrentMonth: true,
                          hasTransactions: true)
    DayButton(date: dummy)
}
