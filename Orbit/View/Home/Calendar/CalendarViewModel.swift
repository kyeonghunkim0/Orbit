//
//  CalendarViewModel.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import Foundation
import Combine

struct DateValue: Identifiable {
    var id: String = UUID().uuidString
    var day: Int
    var date: Date
}

final class CalendarViewModel: ObservableObject {
    
    @Published var currentDate: Date = Date()
    @Published var currentMonth: Int = 0
    
    /// 년과 월로 구성된 String 가져오기
    /// - Parameter date: 현재 Date
    /// - Returns: 년도와 월(2025 9월)
    func getYearAndMonthString(from date: Date) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let date = formatter.string(from: date)
        return date.components(separatedBy: " ")
    }
    
    /// 현재 캘린더의 월 구하기
    /// - Parameter month: 월
    /// - Returns: 현재 캘린더의 Date 타입의 월
    func getCurrentMonth(from month: Int) -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month,
                                               value: month,
                                               to: Date())
        else { return Date() }
        
        return currentMonth
    }
    
    func convertDateToDateValue(from currentMonth: Int) -> [DateValue] {
        let calendar = Calendar.current
        
        let currentCalendar = getCurrentMonth(from: currentMonth)
        
        var days = currentCalendar.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        // month의 가장 처음 시작되는 달
        let firstDayOfWeek = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        // month의 가장 첫날이 되는 요일 이전을 '이전 달 날짜'로 채우기
        let leadingCount = max(firstDayOfWeek - 1, 0)
        if leadingCount > 0 {
            // 이전 달
            guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentCalendar),
                  let prevMonthRange = calendar.range(of: .day, in: .month, for: prevMonth) else {
                return days
            }
            let prevMonthDayCount = prevMonthRange.count
            let startDay = prevMonthDayCount - leadingCount + 1
            for d in startDay...prevMonthDayCount {
                if let prevDate = calendar.date(bySetting: .day, value: d, of: prevMonth) {
                    days.insert(DateValue(day: d, date: prevDate), at: 0)
                }
            }
        }
        
        return days
    }
}
