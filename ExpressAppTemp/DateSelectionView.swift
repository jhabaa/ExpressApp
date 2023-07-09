//
//  DateSelectionView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 29/04/2022.
//

import SwiftUI


//Entending date to get the current Month... and Date
extension Date{
    func GetAllDates() -> [Date]{
        let calendar = Calendar.current
        
        //On prend la date du jour
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for:startDate)!

        //getting date
        return range.compactMap{ day -> Date in
            
            return calendar.date(byAdding: .day, value: day - 1, to : startDate)!
        }
    }
}

//On extrait le mois et l'année
public func extraData(a:Date) -> [String]{
    let formatDate = DateFormatter()
    formatDate.dateFormat = "YYYY MMMM EE"
    let date = formatDate.string(from: a)
    
    return date.components(separatedBy: " ")
}
///Function to get days of a week depending of the lang :-)
public func getWeekDays()->[String]{
    let formatDate = DateFormatter()
    formatDate.dateFormat = "EE"
    
    var result:[String] = Calendar.current.shortStandaloneWeekdaySymbols
    var r = 1
    result.removeLast()
    result.removeFirst()
    
    return result
}

public func getCurrentMonth(currentMonth:Int) -> Date{
    
    let calendar = Calendar.current
    guard let currentMonth = calendar.date(byAdding: .month,value: currentMonth, to: Date()) else{
        return Date()
    }
    return currentMonth
}
public func getNextMonth(currentMonth:Int) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-DD"
    let calendar = Calendar.current
    guard let nextMonth = calendar.date(byAdding: .month,value: currentMonth + 1, to: Date()) else{
        return formatter.date(from: "2200-01-01")!
    }
    return nextMonth
}
public func getPrevMonth(currentMonth:Int) -> Date{
    
    let calendar = Calendar.current
    guard let prevMonth = calendar.date(byAdding: .month,value: currentMonth - 1, to: Date()) else{
        return Date()
    }
    return prevMonth
}

//Fonction qui vérifie si les jours sont les mêmes
public func isSameDay(date1:Date, date2:Date) -> Bool{
    let calendar = Calendar.current
    return calendar.isDate(date1, inSameDayAs: date2)
}

    func extractDates(currentMonth:Int) -> [DateValue]{
    //getting current date
    let calendar = Calendar.current
    let currentMonth = getCurrentMonth(currentMonth: currentMonth)
    
    var days = currentMonth.GetAllDates().compactMap { date -> DateValue
        in
        //getting Day
        let day = calendar.component(.day, from: date)
        //excluding weekends
        let weekend = calendar.component(.weekday, from: date)
        if weekend != 1 && weekend != 7 {
            return DateValue(day: day, date: date)
        }
        return DateValue(day: -0, date: date)
        
    }
    //On ajuiste le jour à la date
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
    print("first day week \(firstWeekDay)")
        if firstWeekDay > 1{
            for _ in 1..<firstWeekDay - 1{
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
        }
    
    //delete values with 0 which are week ends
        days = days.filter{$0.day != 0}
    
    return days
}



