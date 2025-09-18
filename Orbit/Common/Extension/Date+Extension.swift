//
//  Date+Extension.swift
//  Orbit
//
//  Created by 김경훈 on 9/18/25.
//

import Foundation

extension Date {
    
    /// 현재 월의 날짜를 Date 배열로 변환
    /// - Returns: 현재 월의 날짜 Data 배열
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month],
                                                                            from: self))!
        let range = calendar.range(of: .day,
                                   in: .month,
                                   for: startDate)!
        
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day,
                          value: day - 1,
                          to: startDate) ?? Date()
        }
    }
    
    /// 같은 날인지 확인
    /// - Parameter other: 비교하려는 Date
    /// - Returns: 같은 날인지 유무
    func isSameDay(as other: Date) -> Bool {
           Calendar.current.isDate(self, inSameDayAs: other)
    }
}
