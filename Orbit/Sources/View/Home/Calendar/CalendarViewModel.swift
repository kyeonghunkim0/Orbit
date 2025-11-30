//
//  CalendarViewModel.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import Foundation
import Combine


struct DateValue: Identifiable {
    
    /// UUID
    var id: String = UUID().uuidString
    
    /// 일
    var day: Int
    
    /// 날짜 Date
    var date: Date
    
    /// 현재 월 인지
    var isCurrentMonth: Bool
    
    /// 지출 또는 소비 여부
    var hasTransactions: Bool
}

final class CalendarViewModel: ObservableObject {
    
    /// 현재 날짜
    @Published var currentDate: Date = Date()
    
    /// 현재 달
    @Published var currentMonth: Int = 0
    
    /// 선택된 날짜
    @Published var selectedDate: Date? = Date()
    
    /// 금일 총 소비 지출 총액
    /// - Parameter transactions: 총 소비 내역 배열
    /// - Returns: 금일 금액
    func calculateTotalAmount(from transactions: [Transaction]) -> Double {
        return transactions
            .map { $0.amount}
            .reduce(0, +)
    }
    
    /// 캘린더 상단에 20XX년 X월 문자열
    var monthAndYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: currentDate)
    }
    
    /// 날짜 선택
    /// - Parameter date: 선택된 날짜
    func selectDate(date: Date) {
        // 이미 선택된 날짜를 다시 선택하면 선택 해제 (nil)
        if let selected = selectedDate, Calendar.current.isDate(selected, inSameDayAs: date) {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }
    
    /// 월 이동
    /// - 캘린더에서 1개월 씩 넘어갈 때마다 호출됨
    /// - Parameter value: 얼마나 이동할 지 값
    func moveMonth(by value: Int) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) else { return }
        self.currentDate = newDate
    }
    
    /// Date 타입을 DataValue 타입으로 변환
    func convertDateToDateValue() -> [DateValue] {
        let calendar = Calendar.current
        
        let currentCalendar = currentDate
        
        // 현재 월의 모든 날짜 생성
        let currentMonthDays = currentCalendar.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date, isCurrentMonth: true, hasTransactions: false)
        }
        
        var allDays: [DateValue] = []
        
        // 현재 월의 첫 날이 시작하는 요일의 인덱스
        let firstDayOfCurrentMonth = currentMonthDays.first?.date ?? Date()
        let firstDayOfWeek = calendar.component(.weekday, from: firstDayOfCurrentMonth)
        
        // 이전 달의 날짜 추가
        let leadingCount = firstDayOfWeek - 1
        if leadingCount > 0 {
            guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth) else { return [] }
            let prevMonthDays = prevMonth.getAllDates()
            let prevMonthComponents = calendar.dateComponents([.year, .month], from: prevMonth)
            
            for d in (prevMonthDays.count - leadingCount + 1)...prevMonthDays.count {
                var components = prevMonthComponents
                components.day = d
                if let prevDate = calendar.date(from: components) {
                    allDays.append(DateValue(day: d, date: prevDate, isCurrentMonth: false, hasTransactions: false))
                }
            }
        }
        
        allDays.append(contentsOf: currentMonthDays)
        
        // 다음 달의 날짜 추가 (총 42개로 맞추기 위함)
        let trailingCount = 42 - allDays.count
        if trailingCount > 0 {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfCurrentMonth) else { return [] }
            let nextMonthComponents = calendar.dateComponents([.year, .month], from: nextMonth)
            
            for d in 1...trailingCount {
                var components = nextMonthComponents
                components.day = d
                if let nextDate = calendar.date(from: components) {
                    allDays.append(DateValue(day: d, date: nextDate, isCurrentMonth: false, hasTransactions: false))
                }
            }
        }
        
        return allDays
    }
}
