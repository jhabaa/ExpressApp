//
//  Coupon.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 01/07/2023.
//

import Foundation

struct Coupon:Codable,Hashable{
    var id:Int = Int(0)
    var code:String
    var discount:Decimal
    init() {
        self.code = String.init()
        self.discount = Decimal(0)
    }
    init(_ code:String, _ cost:Decimal) {
        self.code = code
        self.discount = cost
    }
    
    /// Set discount
    mutating func setDiscount(_ d:Decimal){
        self.discount = d
    }
    
    /// Function to check and return the value of a coupon
    func Check_Coupon()async -> Decimal{
        guard let encoded = try? JSONEncoder().encode(self) else{
            return 0.0
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/checkcoupon")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let result = try JSONDecoder().decode([Coupon].self, from: data)
            print("Coupon ajouté")
            if result.isEmpty{
                return 0.0
            }else{
                return result.first!.discount
            }
        } catch{
            print("Upload impossible")
            return 0.0
        }
    }
    
    /// Delete a coupon in the server too
    func Delete_Coupon()async{
        guard let encoded = try? JSONEncoder().encode(self) else{
            DispatchQueue.main.async {
                //self.userdata.notification = "Erreur de connexion!"
            }
            return
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/deletecoupon")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            DispatchQueue.main.async {
                //self.userdata.notification = "Coupon supprimé"
            }
            
        } catch{
            DispatchQueue.main.async {
                //self.userdata.notification = "Erreur!"
            }
            print("Retrieve impossible")
            
        }
    }

    /// Add a coupon to the server
    func Add_Coupon() async -> Bool{
            guard let encoded = try? JSONEncoder().encode(self) else{
                DispatchQueue.main.async {
                    //self.userdata.notification = "Erreur de connexion!"
                }
                return false
            }
            let url = URL(string:"http://\(urlServer):\(urlPort)/addcoupon")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.httpMethod = "POST"
            do{
                let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
                print("Coupon ajouté")
                return true
                
            } catch{
                DispatchQueue.main.async {
                    //self.userdata.notification = "Erreur!"
                }
                print("Upload impossible")
                return false
            }
    }
    
    ///Fonction qui ajoute un coupon
    func PushCoupon() async -> Bool{
        
        guard let encoded = try? JSONEncoder().encode(self) else{
            print("erreur d'encodage")
            DispatchQueue.main.async {
                //self.userdata.notification = "Erreur de connexion!"
            }
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/addcoupon")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            DispatchQueue.main.async {
                //self.userdata.notification = "Coupon ajouté"
            }
            print("Added Coupon")
            return true
        } catch{
            print("Upload impossible")
            DispatchQueue.main.async {
                //self.userdata.notification = "Erreur!"
            }
            return false
        }
    }
    
}

final class Coupons:ObservableObject{
    @Published var this:Coupon = Coupon()
    @Published var all:[Coupon]=[]
    
    func Retrieve_Coupons() async throws {
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getcoupons") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            DispatchQueue.main.async {
                //self.userdata.notification = "Erreur de connexion!"
            }
        }
        let task = URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            do {
                guard let data = data, error == nil else {
                    throw NSError()
                }
                
                // Traiter les données ici
                let coupons = try JSONDecoder().decode([Coupon].self, from: data)
                DispatchQueue.main.async {
                    self.all = coupons
                }
               
            } catch {
                print("Erreur lors de la récupération des coupons:", error.localizedDescription)
            }
        }
        task.resume()
    }
    
    //Récupérer tous les coupons
    /*
    func fetchCoupons(){
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getcoupons") else{
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
                let coupons = try JSONDecoder().decode([Coupon].self, from: data)
                
                DispatchQueue.main.async {
                    self.all = coupons
                }
            }catch{
                print (error)
            }
        }
        task.resume()
    }
    */
    
    
    //Fonction qui met à jour un coupon
    func PutCoupon(coupon:Coupon) async -> Bool{
        
        guard let encoded = try? JSONEncoder().encode(coupon) else{
            print("erreur d'encodage")
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/putcoupon")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Updated Coupon")
            return true
        } catch{
            print("Upload impossible")
            return false
        }
    }
    
    func clean(){
        this = Coupon()
    }
}


