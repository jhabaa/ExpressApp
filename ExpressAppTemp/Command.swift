//
//  Command.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 30/06/2023.
//

import Foundation

struct Command:Hashable,Codable{
    var id:Int = Int.init()
    var infos:String
    var cost:Decimal
    var enter_date:String
    var return_date:String
    var date_:String
    var services_quantity:String
    var agent:Int
    var user:Int32?
    var enter_time:String = String.init(0)
    var return_time:String = String.init(0)
    var sub_total:Decimal = Decimal()
    var delivery:Decimal = 0.0
    var discount:Decimal=0.0
    
    //
    init(user: Int32, status:String, cost:Decimal, dateIn:Date, message:String) {
        self.infos = status
        self.cost = Decimal()
        self.enter_date = Date.now.mySQLFormat()
        self.return_date = Date.now.mySQLFormat()
        self.date_ = Date.now.mySQLFormat()
        self.services_quantity = message
        self.agent = 0
        self.user = user
    }
    init() {
        self.infos = String()
        self.cost = Decimal()
        self.enter_date = Date.init().mySQLFormat()
        self.return_date = Date.init().mySQLFormat()
        self.date_ = Date.init().mySQLFormat()
        self.services_quantity = String()
        self.agent = 1
        self.user = Int32()
    }
    init(_i:Int) {
        self.infos = String()
        self.cost = Decimal()
        self.enter_date = Date.init().mySQLFormat()
        self.return_date = Date.init().mySQLFormat()
        self.date_ = Date.init().mySQLFormat()
        self.services_quantity = "8:4,6:1"
        self.agent = 1
        self.user = Int32()
    }
    
    var isValid:Bool{
        return self.enter_time != "0" && self.return_time != "0" && self.enter_date != Date().mySQLFormat() && self.return_date != Date().mySQLFormat()
    }
    
    var isEditable:Bool{
        let modification_delay:Int = 48 // Number of days before the enter date to allow modifications
        return max(0, Int(Date.now.timeIntervalSince(self.enter_date.toDate())/3600)) >= modification_delay ? false : true
    }
    /// Function to send a command
    
   
}

final class Commande:Panier{
    @Published var this : Command = Command()
    @Published var all : [Command] = []
    @Published var confirmed:Bool=false
    @Published var edit:Bool = false
    //Getters & Setters
    
    /// Set current command info
    func setInfos(_ s:String){
        this.infos = s
    }
    
    /// All User commands
    func currentUserCommands(_ user:User)->[Command]{
        return self.all.filter({$0.user == user.id})
    }
    
    
    func validate(_ user:Utilisateur) async{
        
        //send
        DispatchQueue.main.sync {
            self.this.user = user.this.id
            self.this.sub_total = self.getCost
            //self.this.discount = coupon.discount
            self.this.services_quantity = self.CartToString
            self.this.cost = self.getCost + self.this.delivery - self.this.discount
            self.confirmed = true
            //self.this.id = await self.PushCommand()
        }
    }
    
    /// Set current command cost
    func setCost(_ d:Decimal){
        this.cost = d
    }
    
    /// Set current command cart with services and quantities
    func setCart(_ p:Panier){
        
    }
    
    /// Set current command user
    func setUser(_ u:User){
        this.user = u.id
    }
    
    ///Erase the command and the cart
    override func erase() {
        // Clean cart
        self.services.removeAll()
        // Clean Command datas
        self.this = Command()
    }
    
    /// Set current command enter time
    func setTimeIn(_ t:String){
        this.enter_time = t
    }
    
    /// Set current coammand return time
    func setTimeOut(_ t:String){
        this.return_time = t
    }
    
    /// Set the sub total of the command
    var subTotal:Decimal{
        return self.getCost
    }
    
    /// Set delivery cost for the given user
    func setDeliveryCost(_ user:User) async{
        guard let encoded = try? JSONEncoder().encode(user) else{
            return
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/getdeliveryprice")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Delivery cost is : \(data) €")
            guard let deliveryPrice = Decimal(string: String(decoding:data, as: UTF8.self))else{
                print("Données mal formatées")
                return
            }
            print("\(deliveryPrice) €")
            DispatchQueue.main.async {
                self.this.delivery = deliveryPrice
            }
        } catch{
            print("Adresse introuvable")
        }
    }
    
    func setDiscount(_ value:Decimal){
        this.discount = value
    }
    
    /// Set the date to get the article to the client
    func setDateIn(_ date:Date){
        this.enter_date = date.mySQLFormat()
        this.return_date = Calendar.current.date(byAdding: .day, value: self.daysNeeded(), to: date)!.mySQLFormat()
    }
    /// Set the date to get back the article to the client
    func setDateOut(_ date:Date){
        this.return_date = date.mySQLFormat()
    }
    

    // Here are functions to communicate with the server
    ///Fonction qui renvoie toutes les commandes
    func fetch(){
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getcommands") else{
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
                let command = try JSONDecoder().decode([Command].self, from: data)
                DispatchQueue.main.async {
                    self?.all = command
                }
            }catch{
                print (error)
            }
        }
        task.resume()
    }
    
    /// Fonction qui renvoie les commandes d'un utilisateur précis
    func fetchForuser(_ user:User) async{
        guard let encoded = try? JSONEncoder().encode(user) else{
            return
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/getusercommands")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let result = try JSONDecoder().decode([Command].self, from: data)
           
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.all = result
                }
            }
        } catch{
            print("Rettrive impossible")
            
        }
    }
    
    
    ///fonction qui ajoute une commande dans une BD
    func PushCommand() async -> Int {
        print(this)
        guard let encoded = try? JSONEncoder().encode(self.this) else{
            return 0
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/addcommand")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Commande effectuée")
            // Read the command id sent as response
            let response = String(data: data, encoding: .utf8)
            print("Le numero de la command est : \(response)")
            DispatchQueue.main.sync {
                self.this.id = Int(response!)!
            }
            return Int(response!)!
        } catch{
            print("Upload impossible")
            return 0
        }
    }
    
    /// Function to update a command on the server
    /// - Parameter _command: command to update
    /// - Returns: Returns true if command is updated successfully, false otherwise
    func Put_Command() async -> Bool{
        print(self.this)
        guard let encoded = try? JSONEncoder().encode(this) else{
            print("erreur d'encodage")
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/updatecommand")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Updated Command")
            return true
        } catch{
            print("Upload command impossible")
            return false
        }
    }
    
    ///Function to recover with an entry message styled as ServiceID:Quantity,
    /// an dictionnary Panier and return it
    func ReadCommand_List(list:String, article:Article) -> Panier{
        print(list)
        var panier:Panier = Panier()
        if list.contains(","){
            for element in list.split(separator: ","){
                print(element)
                let serviceID = Int(element.split(separator: ":")[0])!
                let quantity = Int(element.split(separator: ":")[1])!
                
                //panier.toCart(Achat(article.GetService(serviceID, quantity)))
                panier.toCart(Achat(article.GetService(id: serviceID), quantity))
                
            }
        }else{ //no comma, then we have only one article
            let serviceID = Int(list.split(separator: ":")[0])!
            let quantity = Int(list.split(separator: ":")[1])!
            panier.toCart(Achat(article.GetService(id: serviceID), quantity))
            //result_list[self.all_services[serviceID]!] = Int(exactly: quantity)!
        }
        
        return panier
    }
    
    ///get total cost of the command test
    var TotalCost:Decimal{
        //self.this.cost = self.getCost + self.this.delivery - self.this.discount
        return self.getCost + self.this.delivery - self.this.discount
    }
    
    /// function which return true if a mission is available that day
    func getToday(_ date:Date)->Bool{
        return self.all.contains(where: {$0.enter_date == date.mySQLFormat()})
    }
    func returnToday(_ date:Date)->Bool{
        return self.all.contains(where: {$0.return_date == date.mySQLFormat()})
    }
    
    ///Function to set edit mode
    func editMode(_ commande:Command){
        self.this = commande
        self.edit = true
    }
    func editModeOff(){
        // Close the view
        self.edit = false
    }
    
    func Commands_Hours_Dict(date:Date) -> [Int:[Command]]{
        var result:[Int:[Command]] = [:]
        //Initialization. We want to always show all hours
        for a in 9...20{
            result[a] = []
        }
        //Now wa have it, we can add commands of the date
        
        
        for command in self.all.filter({$0.enter_date == date.mySQLFormat()}) {
            result[Int(command.enter_time)!]?.append(command)
        }
        for command in self.all.filter({$0.return_date == date.mySQLFormat()}) {
            result[Int(command.return_time)!]?.append(command)
        }
        return result
    }
}
