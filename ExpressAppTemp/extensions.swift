//
//  extensions.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 05/05/2023.
//

import Foundation

extension String{
    
    /// Extension to return the date from a String. it can take a value style depending of the style we want to get
    /// - Parameter style: syle we want. "mysql" or empty for yyyy/MM/dd
    /// - Returns: return a Date 
   func toDate(_ style:String = String())->Date{
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = style == "mysql" ? "yyyy-MM-dd HH:mm:ss" : "yyyy/MM/dd"
            
        return dateFormatter.date(from: self)!
        
    }
}

//Date extensions
extension Date{
    
    /// Set_limit function will return a Date added by the diven number of days excluding work days
    /// - Parameter x: Number of days to added to self date
    /// - Returns: The new date
    func set_limit(_ x:Int)->Date{
        let calendar:Calendar = Calendar.init(identifier: .gregorian)
        var limit_date = self
        var limit_date_component = calendar.dateComponents([.weekday], from: limit_date)
        repeat{
            limit_date = calendar.date(byAdding: .hour, value: 24, to: limit_date)!
            limit_date_component = calendar.dateComponents([.weekday], from: limit_date)
        }while(Int(limit_date.timeIntervalSince(self)) < (x * 86400) || [1,7].contains(limit_date_component.weekday))
        
        return limit_date
    }
    
    /// Function to return an array of dates which starts as self and ends with the given date.
    /// - Parameter x: last date
    /// - Returns: And Array [Date]
    func datesTil(_ x:Date)->[Date]{
        var r:[Date] = []
        var current:Date = self
        let calendar:Calendar = Calendar.init(identifier: .gregorian)
        repeat {
            r.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }while(current <= x)
        return r
    }
    
    var defaultDate:Date{
        return "2000/01/01".toDate()
    }
    
    var day:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    var month:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
        //return calendar.component(Calendar.Component.month, from:self)
    }
    var monthfull:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
        //return calendar.component(Calendar.Component.month, from:self)
    }
    
    func get_month()->Int{
        let calendar:Calendar = Calendar.init(identifier: .gregorian)
        return calendar.dateComponents([.month], from: self).month!
    }
    
    func formatDate()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "dd-MMM-YYYY"
        return dateformater.string(from: self)
    }
    func dateUserfriendly()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "EEEE dd MMMM YYYY"
        return dateformater.string(from: self)
    }
    
    func mySQLFormat()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy/MM/dd"
        return dateformater.string(from: self)
    }
    func dribbleStyle()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy.MM.dd"
        return dateformater.string(from: self)
    }
    
    func isEqualTo(_ s:String)->Bool{
        let newDate = s.toDate()
        return self == s.toDate()
    }
}


let dateRange: ClosedRange<Date> = {
    let calendar = Calendar.current
    let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    let endComponents = DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59)
    return calendar.date(from: startComponents)!
        ...
        calendar.date(from:endComponents)!
}()



let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
}()

