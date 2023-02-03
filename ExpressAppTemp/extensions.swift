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
    
    func get_month()->Int{
        let calendar:Calendar = Calendar.init(identifier: .gregorian)
        return calendar.dateComponents([.month], from: self).month!
    }
}
