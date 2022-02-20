//
//  Date+MMEasy.swift
//  MMFoundation
//
//  Created by Mingle on 2022/2/16.
//

import Foundation

public struct MMDateComponents {
    /// 纪元
    var era: Int
    
    var year: Int
    
    var month: Int
    
    var day: Int
    
    var hour: Int
    
    var minute: Int
    
    var second: Int
    
    var weekday: Int
    
    var weekdayOrdinal: Int
    
    /// 刻
    var quarter: Int
    
    var weekOfMonth: Int
    
    var weekOfYear: Int
    
    var yearForWeekOfYear: Int
    
    /// 纳秒；十亿分之一秒
    var nanosecond: Int
}

public extension Date {
    
    typealias DateComponent = Calendar.Component
    typealias DateIdentifier = Calendar.Identifier
    
    func toString(dateFormatString: String) -> String? {
        return mm_dateToString(self, dateFormatString: dateFormatString)
    }
    
    func toString(createDateFormat: () -> DateFormatter) -> String? {
        return mm_dateToStrirng(self, createDateFormat: createDateFormat)
    }
    
    static func dateWithString(_ dateString: String, createDateFormat: () -> DateFormatter) -> Date? {
        let fmt = createDateFormat()
        return fmt.date(from: dateString)
    }
    
    static func dateWithString(_ dateString: String, dateFormatString: String) -> Date? {
        return dateWithString(dateString) {
            let fmt = DateFormatter()
            fmt.dateFormat = dateFormatString
            return fmt
        }
    }
    
    static func dateWithYear(_ year: Int, month: Int, day: Int) -> Date {
        return dateWithString("\(year)-\(month)-\(day)", dateFormatString: "yyyy-MM-dd")!
    }
    
    /// 获取日期元素
    /// - Parameters:
    ///   - component: 元素部分
    ///   - identifier: 日历类型
    ///   - timeZone: 时区
    /// - Returns: 元素值
    func component(_ component: DateComponent, identifier: DateIdentifier = .gregorian, timeZone: TimeZone = .current) -> Int {
        var calendar = Calendar(identifier: identifier)
        calendar.timeZone = timeZone
        return calendar.component(component, from: self)
    }
    
    /// 获取日期元素结构
    /// - Parameters:
    ///   - identifier: 日历列席
    ///   - timeZone: 时区
    /// - Returns: 元素结构
    func components(identifier: DateIdentifier = .gregorian, timeZone: TimeZone = .current) -> MMDateComponents {
        var calendar = Calendar(identifier: identifier)
        calendar.timeZone = timeZone
        return MMDateComponents(era: calendar.component(.era, from: self), year: calendar.component(.year, from: self), month: calendar.component(.month, from: self), day: calendar.component(.day, from: self), hour: calendar.component(.hour, from: self), minute: calendar.component(.minute, from: self), second: calendar.component(.second, from: self), weekday: calendar.component(.weekday, from: self), weekdayOrdinal: calendar.component(.weekdayOrdinal, from: self), quarter: calendar.component(.quarter, from: self), weekOfMonth: calendar.component(.weekOfMonth, from: self), weekOfYear: calendar.component(.weekOfYear, from: self), yearForWeekOfYear: calendar.component(.yearForWeekOfYear, from: self), nanosecond: calendar.component(.nanosecond, from: self))
    }
    
    /// 去掉时分秒
    func trimmingHMS() -> Date {
        let myComponents = components()
        return Date.dateWithYear(myComponents.year, month: myComponents.month, day: myComponents.day)
    }
    
    var isToday: Bool {
        let todayComponents = Date().components()
        
        let myComponents = components()
        return todayComponents.year == myComponents.year && todayComponents.month == myComponents.month && todayComponents.day == myComponents.day
    }
    
    var isYestoday: Bool {
        let today = Date().trimmingHMS()
        let thisDay = trimmingHMS()
        return today.timeIntervalSince1970 - thisDay.timeIntervalSince1970 == 24 * 60 * 60
    }
    
    var isTomorrow: Bool {
        let today = Date().trimmingHMS()
        let thisDay = trimmingHMS()
        return thisDay.timeIntervalSince1970 - today.timeIntervalSince1970 == 24 * 60 * 60
    }

}
