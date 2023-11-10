//
//  User.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 01/07/2023.
//

import Foundation

struct User:Codable,Hashable{
    //static var loggedIn:Bool = false
    var id:Int32
    var name:String
    var surname:String
    var mail:String
    var phone:String
    var adress:String
    var password:String
    var type:String
    var loc_lat:Float=0.0
    var loc_lon:Float=0.0
    var province:String=""
    
    
    init() {
        self.id = Int32()
        self.name = String.init()
        self.surname = String.init()
        self.mail = String()
        self.phone = String()
        self.adress = String()
        self.password = String.init()
        self.type = "user"
    }
    init(username:String, password:String) {
        self.id = Int32()
        self.name = username
        self.surname = String.init()
        self.mail = String.init()
        self.phone = String()
        self.adress = String.init()
        self.password = password
        self.type = "user"
    }
    init(name: String) {
        self.id = 1
        self.name = name
        self.surname = "Doe"
        self.mail = "\(name.lowercased())@example.com"
        self.phone = "01234567890"
        self.adress = "Rue de ter Plast 45 1020 Bruxelles/Brussel"
        self.password = "password"
        self.type = "admin"
        self.loc_lat = 50.8817
        self.loc_lon = 4.34475
        self.province = "Région de Bruxelles-Capitale/Brussels Hoofdstedelijk Gewest"
    }

    var isAdmin:Bool{
        return self.type.contains("admin") ? true : false
    }
    var isUser:Bool{
        return self.type.contains("user") ? true : false
    }
    var isValidBelgianGSM:Bool{
        return true
    }
    
    /// This variable is set to true if the current user is not correct
    var isEmpty:Bool{
        return self.name.isEmpty || self.password.isEmpty || self.mail.isEmpty
    }
    
    func update()async -> (Bool,User){
            guard let encoded = try? JSONEncoder().encode(self) else{
                print("Erreur d'encodage")
                return (false,User())
            }
            let url = URL(string:"http://\(urlServer):\(urlPort)/updateuser")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.httpMethod = "POST"
            do{
                let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Reponse de connexion daux données \(responseString)")
                    let updatedUser = try JSONDecoder().decode(User.self, from: data)
                    print("utilisateur mis à jour \(updatedUser)")
                    return (true, updatedUser)
                } else {
                    print("Impossible de convertir les données de la réponse en texte")
                    return (false,User())
                }
            } catch{
                return (false, User())
            }
    }
    
    func readAdress(_ data:[String])->Bool{
        let result:Bool = !data[0].isEmpty && data[1].allSatisfy({$0.isNumber || $0.isLetter}) && data[3].count==4 && data[3].allSatisfy({$0.isNumber}) && !data[4].isEmpty
        return result
    }
    
    
    func get_adress_datas()->(String, String, String, String, String){
        var result:[String] = []
        let pattern = #"^(.+?)\s+(\d+[a-z]?)\s*(.*?)\s*(\d{4})\s+(.+)$"#
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            if let match = regex.firstMatch(in: adress, range: NSRange(adress.startIndex..., in: adress)) {
                let street = String(adress[Range(match.range(at: 1), in: adress)!])
                let number = String(adress[Range(match.range(at: 2), in: adress)!])
                let supplement = String(adress[Range(match.range(at: 3), in: adress)!])
                let postalCode = String(adress[Range(match.range(at: 4), in: adress)!])
                let city = String(adress[Range(match.range(at: 5), in: adress)!])
                
                result.append(street)
                result.append(number)
                result.append(supplement)
                result.append(postalCode)
                result.append(city)
                return (street, number, supplement, postalCode, city)
            }
            
        } catch {
            print("Invalid pattern: \(error.localizedDescription)")
        }
        return ("","","","","")
    }
    
    ///Function which return true if the email is correct
    var isMailIsCorrect : Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self.mail)
    }
}

final class Utilisateur:ObservableObject{
    @Published var this:User = User(name:"John")
    @Published var review:User = User(name:"John")
    @Published var all:Set<User> = []
    
    
    /// Function to reset the password of a given user
    /// - Parameter user: the user that we want to recover datas
    /// - Returns: true if recovery process done. False otherwise
    func ResetPassword(_ user:User)->Bool{
        guard let encoded = try? JSONEncoder().encode(user) else{
            return false
        }
        print("Reinitialization for mail : \(user.mail)")
        let url = URL(string: "http://\(urlServer):\(urlPort)/reset?mail=\(user.mail)")!
        let task2 = URLSession.shared.dataTask(with: url)
        task2.resume()
        return true
    }
    
    func register() async -> Bool{
        guard let encoded = try? JSONEncoder().encode(self.this) else{
            
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/register")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            // Read the command id sent as response
            let response = String(data: data, encoding: .utf8)
            print("Le numero d'utilisateur est : \(response ?? "")")
            
            DispatchQueue.main.async {
                self.this.id = Int32(Int(response!)!)
            }
            return true
        } catch{
            return false
        }
    }
     
    func delete(_ user:User)async -> Bool{
        guard let encoded = try? JSONEncoder().encode(user) else{
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/deleteuser")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Reponse de connexion daux données \(data)")
            let result = try JSONDecoder().decode(String.self, from: data)
            print(result)
            if result=="True"{
                return true
            }else{
                return false
            }
        } catch{
            return false
        }
    }
    
    /// Function to identify a user. User is identify with username or email.
    /// - Parameter user: user to check. username or email and password are required
    /// - Returns: The first user that matches with the given one. Type User, nil else
    func connect(user:User) async -> User?{
        guard let encoded = try? JSONEncoder().encode(user) else{
            return nil
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/connect")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            if let responseString = String(data: data, encoding: .utf8) {
                print("Reponse de connexion daux données \(responseString)")
                return try JSONDecoder().decode(User.self, from: data)
            } else {
                print("Impossible de convertir les données de la réponse en texte")
                return nil
            }
        } catch{
            print("Erreur inconnue")
            return nil
        }
    }
    
    ///Fontion qui renvoie la liste des utilisateurs
    func fetch(){
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getusers") else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){ [weak self]
            data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            //convert from JSON
            do{
                let users = try JSONDecoder().decode(Set<User>.self, from: data)
                
                DispatchQueue.main.async {
                    self?.all = users
                }
            }catch{
                print (error)
            }
        }
        task.resume()
    }
    
    ///Fonction qui prend un id et renvoie l'utilisateur concerné
    func userWithId(_ id:Int32)->User{
        return self.all.first(where: {$0.id == id}) ?? User(name: "inconnu")
    }
    
    
}
