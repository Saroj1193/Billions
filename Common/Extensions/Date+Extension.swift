//
//  Date+Extension.swift
//  
//
//  Created by Tristate on 11/18/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation


extension Date {
    
    func getTimeIntervalFromTwoDate(fromDate : String , toDate : String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"//"MM/dd/yyyy HH:mm:ss"
        
        let date = dateFormatter.date(from: fromDate)
        let date1 = dateFormatter.date(from: toDate)
        
        let calendar = NSCalendar.current
        let timeDifference = calendar.dateComponents([.hour,.minute], from: date!, to: date1!)
        let count =  timeDifference.value(for: .hour)!
        let count1 =  timeDifference.value(for: .minute)!
        
        
        if(count > 0){
            return "\(count) hours \(count1) mins."
        }
        else {
            return "\(count1) mins."
        }
        
    }
    
    func getStringFromTimeStamp(_ timeinterval  : TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeinterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    func getDateFromString(_ strDate:String) -> Date {
        if strDate == "" {
            return Date()
        }else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strTodayDate = dateFormatter.string(from: Date())
            
            if strDate.contains(strTodayDate) {
                return Date()
            }
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateValue = dateFormatter.date(from: strDate)
            
            if dateValue == nil {
                return Date()
            }
            
            return dateValue!
            
        }
    }
    
    func getTimeFromDate(_ strDate:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"//"MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        let date = dateFormatter.date(from: strDate)
        dateFormatter.dateFormat = "HH:mm a"
        let strValue = dateFormatter.string(from: date!)
        
        return strValue
    }
    
    func getTimeFromHoursDate(_ strDate:String) -> String {
        let dateFormatter = DateFormatter()
        if(strDate == ""){
            return ""
        }
        if(strDate.count > 6) {
            dateFormatter.dateFormat = "HH:mm:ss"
        }else{
            dateFormatter.dateFormat = "HH:mm"
        }
        //"MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        let date = dateFormatter.date(from: strDate)
        dateFormatter.dateFormat = "HH:mm"
        let strValue = dateFormatter.string(from: date!)
        
        return strValue
    }
    
    func getTimeStampValue(_ strDate:String) -> TimeInterval {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //"MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        let date = dateFormatter.date(from: strDate)
        let timeInterval = date?.timeIntervalSince1970
        return timeInterval!
        
    }
    
    func getTimeStampValueFromDateFormat(_ strDate:String) -> TimeInterval {
        if strDate == "" {
            return Date().timeIntervalSince1970
        }
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //"MM/dd/yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        let date = dateFormatter.date(from: strDate)
        let timeInterval = date?.timeIntervalSince1970
        return timeInterval!
        
    }
    
    func dayDifference(from interval : TimeInterval) -> String
    {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInYesterday(date) { return "YESTERDAY" }
        else if calendar.isDateInToday(date) { return "TODAY" }
        else if calendar.isDateInTomorrow(date) { return "TOMORROW" }
        else {
            
            let date = Date(timeIntervalSince1970: interval)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd. MMMM YYYY"
            dateFormatter.timeZone = TimeZone.current
            let localDate = dateFormatter.string(from: date)
            return localDate
        }
    }
    
    func addOneDay(_ interval : TimeInterval) -> String {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval+86400)
        if calendar.isDateInYesterday(date) { return "YESTERDAY" }
        else if calendar.isDateInToday(date) { return "TODAY" }
        else if calendar.isDateInTomorrow(date) { return "TOMORROW" }
        else {
            
            let date = Date(timeIntervalSince1970: interval+86400)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd. MMMM YYYY"
            dateFormatter.timeZone = TimeZone.current
            let localDate = dateFormatter.string(from: date)
            if date > Date() {
                return localDate
            }else {
                return "YESTERDAY"
            }
            
        }
    }
    
    func setWeekDate(_ interval : TimeInterval) -> String {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval+604800)
        
        if calendar.isDateInToday(date) {
            
            let date1 = Date().addingTimeInterval(86400)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            dateFormatter.timeZone = TimeZone.current
            let localDate = dateFormatter.string(from: date1)
            
            let newLocalDate = dateFormatter.string(from: Date().addingTimeInterval(691200))
            let newDate = localDate + "-" + newLocalDate
            return newDate
        }
        else {
            if date < Date() {
                let date1 = Date(timeIntervalSince1970: interval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM"
                dateFormatter.timeZone = TimeZone.current
                let localDate = dateFormatter.string(from: date1)
                let newLocalDate = dateFormatter.string(from: date)
                let newDate = localDate + "-" + newLocalDate
                return newDate
            }
            else {
                let date1 = Date(timeIntervalSince1970: interval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM"
                dateFormatter.timeZone = TimeZone.current
                let localDate = dateFormatter.string(from: date1)
                let newLocalDate = dateFormatter.string(from: date)
                let newDate = localDate + "-" + newLocalDate
                return newDate
            }
            
        }
    }
    
    func setOneWeekDateFormat(_ interval : TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: interval+518400)
        
        let date1 = Date(timeIntervalSince1970: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date1)
        let newLocalDate = dateFormatter.string(from: date)
        let newDate = localDate + "-" + newLocalDate
        return newDate
    }
    func setAddOneWeekDate(_ interval : TimeInterval) -> String {
        let calendar = NSCalendar.current
        let newTimeInterval = interval+691200
        let date = Date(timeIntervalSince1970: newTimeInterval+604800)
        
        if calendar.isDateInToday(date) {
            let date1 = Date(timeIntervalSince1970: interval)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            dateFormatter.timeZone = TimeZone.current
            let localDate = dateFormatter.string(from: date1)
            let newLocalDate = dateFormatter.string(from: Date())
            let newDate = localDate + "-" + newLocalDate
            return newDate
        }
        else {
            if date < Date() {
                let date1 = Date(timeIntervalSince1970: interval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM"
                dateFormatter.timeZone = TimeZone.current
                let localDate = dateFormatter.string(from: date1)
                let newLocalDate = dateFormatter.string(from: date)
                let newDate = localDate + "-" + newLocalDate
                return newDate
            }
            else {
                
                let date1 = Date(timeIntervalSince1970: newTimeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM"
                dateFormatter.timeZone = TimeZone.current
                let localDate = dateFormatter.string(from: date1)
                let newLocalDate = dateFormatter.string(from: date)
                let newDate = localDate + "-" + newLocalDate
                return newDate
            }
            
        }
    }
    
    func setAddOneWeekAndGetDateFormat(_ interval : TimeInterval) -> String {
        
        let newTimeInterval = interval+604800
        let date = Date(timeIntervalSince1970: newTimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    func setMonthDate(_ interval : TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: interval)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date)
        let currentYear = dateFormatter.string(from: Date())
        if localDate == currentYear {
            dateFormatter.dateFormat = "LLLL"
            dateFormatter.timeZone = TimeZone.current
            let currentMonth = dateFormatter.string(from: date)
            return currentMonth
        }else{
            dateFormatter.dateFormat = "LLLL yyyy"
            dateFormatter.timeZone = TimeZone.current
            let dateNew = dateFormatter.string(from: date)
            return dateNew
        }
    }
    
    func setAddOneMonthDate(_ interval : TimeInterval) -> String {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval)
        let newDate = calendar.date(byAdding: .month, value: 1, to: date)
        
        if newDate! > Date() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            dateFormatter.timeZone = TimeZone.current
            let localDate = dateFormatter.string(from: newDate!)
            let currentYear = dateFormatter.string(from: Date())
            if localDate == currentYear {
                dateFormatter.dateFormat = "LLLL"
                dateFormatter.timeZone = TimeZone.current
                let currentMonth = dateFormatter.string(from: newDate!)
                return currentMonth
            }else{
                dateFormatter.dateFormat = "LLLL yyyy"
                dateFormatter.timeZone = TimeZone.current
                let dateNew = dateFormatter.string(from: newDate!)
                return dateNew
            }
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            dateFormatter.timeZone = TimeZone.current
            let currentMonth = dateFormatter.string(from: Date())
            return currentMonth
        }
        
    }
    
    func localToUTC(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter.string(from: dt!)
    }
    
    func dayDifferenceDay(from interval : TimeInterval) -> String
    {
        var calendar = NSCalendar.current
        calendar.timeZone = .current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInToday(date) {return "Today" }
        
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.minute,.hour,.day,.weekday,.month,.year], from: startOfNow, to: startOfTimeStamp)
        let day = -components.day!
        
        
        let month = -components.month!
        let year = -components.year!
        
        
        if year >  0{
            if year > 1{
                return "\(year) YEARS AGO"
            }else{
                return "\(year) YEAR AGO"
            }
        }else if month > 0{
            if month > 1{
                return "\(month) MONTHS AGO"
            }else{
                return "\(month) MONTH AGO"
            }
        }else{
            if day > 1{
                return "\(day) DAYS AGO"
            }else{
                if day < 0 || day == 0{
                    return "TODAY"
                }else{
                    return "\(day) DAY AGO"
                }
            }
        }
        
    }
    
    func getFormattedDate(format: String) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat  = format
           let aDate = dateFormatter.string(from: self)
           return aDate
    }
    
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

extension Date {
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year,.month,.weekday,.day,.hour,.minute], from: self, to: Date())
        
        let day = interval.day!
        let week = interval.weekday!
        let month = interval.month!
        let year = interval.year!
        let minute = interval.minute!
        let hour = interval.hour!
        
        
        if year >  1{
            if year > 1{
                return "\(year) years ago"
            }else{
                return "\(year) year ago"
            }
        }else if month > 1{
            if month > 1{
                return "\(month) months ago"
            }else{
                return "\(month) month ago"
            }
        }else if week > 1{
            if week > 1{
                return "\(week) weeks ago"
            }else{
                return "\(week) week ago"
            }
        }else if day > 1{
            if day > 1{
                return "\(day) days ago"
            }else{
                return "\(day) day ago"
            }
        }else if hour > 1{
            if hour > 1{
                return "\(hour) hours ago"
            }else{
                return "\(hour) hour ago"
            }
        }else{
            if minute > 1{
                return "\(minute) minutes ago"
            }else{
                return "\(minute) minute ago"
            }
        }
        
    }
}
