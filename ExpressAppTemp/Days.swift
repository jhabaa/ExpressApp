//
//  Days.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 25/10/2023.
//

import Foundation

struct MyDate:Codable {
    var id:Int
    var date:String
    
    init(id: Int, date: String) {
        self.id = id
        self.date = date
    }
}

class Days:ObservableObject{
    @Published var daysOff:[Date]=[]
    var id:Int=Int()
    var date:String = ""
    
    func isNoWorkDay(_ d:Date)->Bool{
        return daysOff.contains(d)
    }
    func remove(_ d:Date)async -> Bool{
        guard let encoded = try? JSONEncoder().encode(MyDate(id: 0, date: d.mySQLFormat())) else{
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/removedayoff")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            return true
        } catch{
            return false
        }
    }
    
    func push(_ d:Date) async -> Bool{
        guard let encoded = try? JSONEncoder().encode(MyDate(id: 0, date: d.mySQLFormat())) else{
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/adddayoff")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            return true
        } catch{
            return false
        }
    }
    
    func removeDayOff(_ d:Date) async -> Bool{
        guard let encoded = try? JSONEncoder().encode(d) else{
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/removedayoff")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            return true
        } catch{
            return false
        }
    }
    
    func Retrieve_daysOff()async -> Bool{
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getdaysoff") else{
            return false
        }
        let task = URLSession.shared.dataTask(with: url){ [weak self]
            data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            //convert from JSON
            do{
                let days = try JSONDecoder().decode([MyDate].self, from: data)
                DispatchQueue.main.async {
                    //Read response and fill the array
                    days.forEach({
                        self!.daysOff.append($0.date.toDate())
                    })
                }
            }catch{
                print (error)
            }
        }
        task.resume()
        return false
    }
}
