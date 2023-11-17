//
//  modelsFetch.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/03/2022.
//

import Foundation
import Combine
import SwiftUI


//=============Pages=================================
class Page:Hashable,Identifiable{
    var id : Int
    let PageName:String
    let PageIcon:String
    var PageLevel:Int
    let type:String
    var Active:Bool
    
    init(PageName: String, pageIcon: String, type: String, active: Bool, pageLevel:Int, id:Int) {
        self.PageName = PageName
        self.PageIcon = pageIcon
        self.type = type
        self.Active = active
        self.PageLevel = pageLevel
        self.id = id
    }
    func toggle(){
        self.Active.toggle()
    }
    static func == (lhs: Page, rhs: Page) -> Bool {
        return lhs.PageName == rhs.PageName &&
        lhs.PageIcon == rhs.PageIcon &&
        lhs.type == rhs.type &&
        lhs.Active == rhs.Active &&
        lhs.PageLevel == rhs.PageLevel &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(PageName)
        hasher.combine(PageIcon)
        hasher.combine(type)
        hasher.combine(Active)
        hasher.combine(PageLevel)
        hasher.combine(id)
    }
}

class focus_elements{
    
    var username:[String:Bool] = ["username":false]
    var password:[String:Bool] = ["password":false]
    var v_password:[String:Bool] = ["v_password":false]
    
    init() {
    }
    var unfocus:Bool{
        return !username["username"]! && !password["password"]! && !v_password["v_password"]!
    }
    
}
//=============Texfield Element =====================
class focusObjects:ObservableObject{
    @Published var focus_in:[String:Bool]=[
        "utilisateur":false,
        "prenom":false,
        "mot de passe":false,
        "v-mot de passe":false,
        "rue":false,
        "numero":false,
        "supplement":false,
        "code postal":false,
        "ville":false,
        "gsm":false,
        "email":false,
        "Catégorie":false,
        "Nom du Service":false,
        "Prix":false
    ]
}



//======================= Structures de données ==================================================


/*
 struct COMMAND_HAS_USER:Hashable, Codable{
 var command_id:Int64
 var user:Int64
 }
 */

/// command service is a class to get the cart easily. Now we can retrieve a cart just as table of self
struct command_service:Codable{
    var command_id:Int = 0
    var service_id:Int = 0
    var quantity:Int = 0
    init(){}
}
struct SERVICE_HAS_COMMAND:Hashable, Codable{
    var service_ID_SERVICE:Int64
    var command_id:Int64
    var quantity:Int
    init(service_ID_SERVICE: Int64, command_id: Int64, quantity: Int) {
        self.service_ID_SERVICE = service_ID_SERVICE
        self.command_id = command_id
        self.quantity = quantity
    }
    
}
struct verification : Codable, Hashable{
    var username:String
    var password:String
}
struct TIMES:Hashable, Identifiable,Codable{
    var id: Int
    var creneau:String
    var state:Int
    var day:String
    var program:Int
}

struct DateValue:Identifiable{
    var id = UUID().uuidString
    var day:Int
    var date:Date
}

//==================================== Settings ===============================================
struct Settings:Hashable, Identifiable, Codable{
    var id: Int = 1
    var update:Int = 0
    var shipZone1:Decimal = Decimal()
    var shipZone2:Decimal = Decimal()
    var shipZone3:Decimal = Decimal()
    var annonce:String = String()
}

struct WorldTimeAPIResponse: Codable {
    let datetime: Date
}

//+============================================================================================


//================================================== Variables =========================================================================

let urlServer:String = "express.heanlab.com"
let urlPort:String = "80"


//============================= Observable Objects =====================================================
//Classe des utilisateurs Hors Ligne
final class UserData:ObservableObject{
    //Publications d'objets persistants
    //@Published var currentUser:User = User.init()
    @Published var user_commands:[Command]=[]
    
    /*
     @Published var currentCommand:NEW_COMMAND = NEW_COMMAND(id: 0,
     STATUS_COMMAND: "unsend",
     cost: 0,
     enter_date: "",
     return_date: "",
     discount_CODE: "0",
     COMMAND_DATE: Date.now.formatDate(),
     services_quantity:"",
     AGENT_ID: Int.zero, user: 3)
     */
    @Published var currentServiceHasCommand : [SERVICE_HAS_COMMAND] = []
    //@Published var commandInCart:[Command] = []
    //@Published var commandHasUSer:[COMMAND_HAS_USER] = []
    //@Published var defaultUser:User = User.init()
    
    //Panier de l'utilisateur
    //@Published var currentCommand:Command = Command.init()
    
    //Dictionnary quantity and service
    //@Published var cart:[Service:Int] = [:] // Then, for each service in the cart, we can add a quantity directly here...
    
    @Published var TestCard:[Service:Int] = [
        Service.init():3,
    ]
    ///
    /// Fonctions de sauvegarde de données persistantes
    
    //Command variables
    //Checkout value
    @Published var checkout:Decimal = 0.0
    @Published var shippingCost:Decimal=0.0
    @Published var discount:Decimal=0.0
    
    //Taskbar Menu
    @Published var taskbar:Bool = true
    @Published var currentPage:Page = Page.init(PageName: "accueil", pageIcon: "house", type: "user", active: true, pageLevel: 0, id: 1)
    //Pages
    //@Published var pages:[String:Bool] = ["accueil":true, "panier":false, "moi":false]
    @Published var pages:[Page:Bool]=[
        Page.init(PageName: "accueil", pageIcon: "house", type: "user", active: true, pageLevel: 0, id: 1 ):true,
        Page.init(PageName: "panier", pageIcon: "cart", type: "user", active: false, pageLevel: 1, id: 2):false,
        Page.init(PageName: "profil", pageIcon: "person.circle", type: "user admin", active: false, pageLevel: 1, id: 3):false
    ]
    var activePage:Page{
        return pages.first(where: {$0.value == true})!.key
    }
    @Published var options:[Page]=[
        Page.init(PageName: "Infos", pageIcon: "person", type: "user", active: false, pageLevel: 3, id: 1),
        Page.init(PageName: "Contacts", pageIcon: "phone", type: "user", active: false, pageLevel: 3, id:2),
        Page.init(PageName: "Commandes", pageIcon: "cart", type: "user", active: false, pageLevel: 3, id: 3)
        
    ]
    @Published var administration:[Page]=[
        Page.init(PageName: "Commandes", pageIcon: "house", type: "user", active: false, pageLevel: 4, id: 1),
        Page.init(PageName: "Utilisateurs", pageIcon: "phone", type: "user", active: false, pageLevel: 4, id: 2),
        Page.init(PageName: "Services", pageIcon: "cart", type: "user", active: false, pageLevel: 4, id: 3),
        Page.init(PageName: "Coupons", pageIcon: "cart", type: "user", active: false, pageLevel: 4, id: 4)
        
    ]
    
    //Commands validators
    @Published var command_checker:[String:Bool] = [
        "panier":false,
        "adresse":false,
        "livraison":false
    ]
    
    
    //Applications variables
    @Published var show_notification:Bool=false
    @Published var notification:String = String()
    
    @Published var loading:Bool = false
    //@Published var currentArticle:Service=Service()
    
    //Real hour
    @Published var dateTime:Date=Date()
    //Hour In
    // @Published var HourIN: Time = .chocolate
    //Hour Out
    // @Published var HourOut: Time = .chocolate
    
    //taskbar states for cart
    @Published var cart_state:[Int:Bool]=[0:true,1:false,2:false,3:false]
    
    //bool to show date selector sheet
    @Published var show_date_selector_view:Bool = false
    
    //Bool to show Recap of a command
    @Published var command_confirmation:Bool = false
    
    
    
    
    
    
    
    
    public static func fileURL() throws -> URL{
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("user.data")
    }
    //To load from user.data file
    static func load(completion: @escaping (Result<User, Error>)->Void){
        DispatchQueue.global(qos: .background).async {
            do{
                var fileURL = try fileURL()
                //Because user.data doesnt exist the first time we launched app, we have to call the completion handler
                //With an empty array if there is an error opening file handle
                guard var file = try? FileHandle(forReadingFrom: fileURL)else{
                    DispatchQueue.main.async {
                        completion(.success(User.init()))
                    }
                    return
                }
                //We decode the file data into a constant
                var userNow = try JSONDecoder().decode(User.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(userNow))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            }
        }
    }
    
    //To delete Data
    public static func removeData(){
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(at: fileURL())
        } catch{
            print(error)
        }
    }
    
    //To save data
    static func save(user: User, completion: @escaping (Result<Int, Error>)->Void) async{
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            do{
                var data = try JSONEncoder().encode(user)
                var outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(1)) //1 for the number of users
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //=====================Command =========================================
    private static func fileURLCommand() throws -> URL{
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("currentcommand.data")
    }
    
    //To load from currentcommand.data file
    static func loadCommand(user_ID:Int32,completion: @escaping (Result<Command, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do{
                var fileURL = try fileURLCommand()
                //Because user.data doesnt exist the first time we launched app, we have to call the completion handler
                //With an empty array if there is an error opening file handle
                guard var file = try? FileHandle(forReadingFrom: fileURL)else{
                    DispatchQueue.main.async {
                        completion(.success(Command.init(user: user_ID, status: "null", cost: Decimal.zero, dateIn: Date.init(), message: "")))
                    }
                    return
                }
                //We decode the file data into a constant
                var commandNow = try JSONDecoder().decode(Command.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(commandNow))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            }
        }
    }
    //Pour sauvegarder une commande en mémoire. Elle sera supprimée si validée
    static func saveCommand(command: Command, completion: @escaping (Result<Int, Error>)->Void){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            do{
                var data = try JSONEncoder().encode(command)
                var outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(1)) //1 for the number of users
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //Get Time from Internet
    func getCurrentDateTime() async{
        guard let url = URL(string: "https://worldtimeapi.org/api/ip") else {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(WorldTimeAPIResponse.self, from: data)
            self.dateTime = result.datetime
            //let formatter = DateFormatter()
            //formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //return formatter.string(from: result.datetime)
        } catch {
            return
        }
    }
    
    //function chick return true if the time between a date A & a date B is greater than 48h
    /// Function which return true if the difference between dates is greater than the given value in hours
    /// - Parameters:
    ///   - date2: Deadline
    ///   - date1: CurrentTime. Automatic if doesnt show
    ///		min_hours: Minimum Time to validate expression
    /// - Returns: Bool
    func hoursBetween(_ date1: Date, _ date2: Date = Date(), _ min_hours: Int) -> Bool {
        return max(0, Int(date2.timeIntervalSince(date1)/3600)) >= min_hours ? true : false
    }
    
    // Fonction de connexion des utilisateurs à l'application
    /*func ConnectToUser(username:String, password:String) async{
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/connecttouser?username=\(username)&password=\(password)") else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){
            
            data, _,
            error in
            guard let data = data, error == nil else{
                return
            }
            // We got a JSON let's convert it
            Task{
                do {
                    let user = try JSONDecoder().decode([User].self, from: data)
                    DispatchQueue.main.async {
                        Task{
                            self.notification = "Connexion reussie"
                            self.currentUser = user.first!
                           // User.connect()
                        }
                    }
                }catch{
                    print("This an error :\(error)" )
                }
            }
            
        }
        task.resume()
    }
    */
    //Fonction qui ajoute un service à une commande
    func AddToServiceHasCommand(id:Int){
        var found:Bool = false
        var a=0
        @EnvironmentObject var userdata:UserData
        self.currentServiceHasCommand.forEach { index in
            if index.service_ID_SERVICE == id{
                self.currentServiceHasCommand[a].quantity += 1
                found.toggle()
            }else{
                a += 1
            }
        }
        if !found{
            self.currentServiceHasCommand.append(SERVICE_HAS_COMMAND(service_ID_SERVICE: Int64(id), command_id: 0, quantity: Int(1)))
            a=0
        }
    }
    
    //Fonction qui met à jour le numéro de commande de service has Command
    /*func UpdateServiceHasCommand() async{
     print(self.currentServiceHasCommand)
     self.currentServiceHasCommand.forEach {
     var index = $0
     index.command_id = self.currentCommand.id
     }
     print(self.currentServiceHasCommand)
     }*/
    
    
    //Fonction qui supprime un service à une commande
    func RemoveToServiceHasCommand(id:Int){
        var found:Bool = false
        var a=0
        @EnvironmentObject var userdata:UserData
        self.currentServiceHasCommand.forEach { index in
            if index.service_ID_SERVICE == id{
                self.currentServiceHasCommand[a].quantity -= 1
                // Si à 0, on efface la ligne.
                if self.currentServiceHasCommand[a].quantity == 0{
                    self.currentServiceHasCommand.remove(at: a)
                }
                found.toggle()
            }else{
                a += 1
            }
        }
    }
    
    //Fonction qui supprime la commande du fichier local après validation
    func DeleteCommandNow(){
        self.currentServiceHasCommand.removeAll()
    }
    
    //Fonction qui dans un un tableau ServiceHasCommand, renvoie une unité en fonction de l'id  du service cerné
    func GetServiceInCommand(id:Int) -> SERVICE_HAS_COMMAND{
        var result:SERVICE_HAS_COMMAND = SERVICE_HAS_COMMAND(service_ID_SERVICE: 0,
                                                             command_id: 0,
                                                             quantity: 0)
        self.currentServiceHasCommand.forEach { index in
            if index.service_ID_SERVICE == id {
                result = index
            }
        }
        return result
    }
    
    //Fonction qui ajoute une unité à un Service has Command
    func AddQuantity(id:Int){
        self.currentServiceHasCommand.forEach {
            var index = $0
            if index.service_ID_SERVICE == id{
                index.quantity += 1
            }
        }
    }
    
    /*
     Function to Add a service to cart
     */
    /*
    func AddServiceToCart(s:Service) {
        if cart.contains(where: { T in
            T.key.id == s.id
        }){
            cart[s]! += 1
            
        }else {
            cart.updateValue(1, forKey: s)
        }
        //self.currentCommand.sub_total += s.cost
    }*/
    /* Function to remove one element in the cart, or delele it if quantity ==  0
     */
    /// Function to remove a service from a cart. just on time. It takes the service itself, and a string "insert" or "update".
    /// - Parameter s: The service itself
    ///
    /*
    func RemoveServiceFromCart(s:Service){
        if cart.contains(where: { T in
            T.key.id == s.id
        }){
            cart[s]! -= 1
            if (cart[s]! == 0){
                cart.removeValue(forKey: s)
            }
            //self.currentCommand.sub_total -= s.cost
        }
    }
    */
    //Function do to convert cart datas to string to store it easily in the database.
    func cartToString(_ dictionary: [Service: Int]) -> String {
        var parts: [String] = []
        for (key, value) in dictionary {
            let part = "\(key.id):\(value)"
            parts.append(part)
        }
        let string = parts.joined(separator: ",")
        return "\(string)"
    }
    func cartToString(_ dictionary: Set<Achat>) -> String {
        var parts: [String] = []
        dictionary.forEach { achat in
            parts.append("\(achat.service.id):\(achat.quantity)")
        }
        let string = parts.joined(separator: ",")
        return "\(string)"
    }
    
    
    //Function to go a specific page
    func GoToPage(goto:String){
        
            pages.forEach { k, v in
                if k.PageName == goto {
                    pages[k] = true
                }else{
                    pages[k] = false
                }
            }
        
        
    }
    
    //Function to get back to a previous page
    func Back(){
        GoToPage(goto: "accueil")
    }
    
    //return the page specified
    func GetPage(page:String)->Page{
        return pages.filter({$0.key.PageName==page}).first!.key
    }
    
    //return tru is a page is active
    func IsActive(pagName:String) -> Bool{
        return pages.filter({$0.key.Active == true}).first!.key.PageName == pagName ? true : false
    }
    
    
    //function to levelup the current page
    func LevelUp(){
        currentPage.PageLevel += 1
        currentPage=currentPage
    }
    //function to levelDown the current page
    func LevelDown(){
        currentPage.PageLevel -= 1
        currentPage=currentPage
    }
    
    //function to go to next check
    func Next_Check(){
        command_checker[command_checker.first(where: {$0.value==false})!.key] = true
    }
    
    //Function to return a check command option
    func Check_Checker(_ name:String)->Bool{
        return self.command_checker[name]!
    }
    
    //Function to check a spécific page
    func Check_Page(_ name:String){
        self.command_checker[name] = true
    }
    
    //Function to uncheck a specific page
    func Uncheck_Page(_ name:String){
        self.command_checker[name] = true
    }
    
    
    //Function to verify if an adress is correct
    func Validate_Adress(address:String)->Bool{
        var result:[String] = []
        let pattern = #"^(.+?)\s+(\d+[a-z]?)\s*(.*?)\s*(\d{4})\s+(.+)$"#
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            if let match = regex.firstMatch(in: address, range: NSRange(address.startIndex..., in: address)) {
                let street = String(address[Range(match.range(at: 1), in: address)!])
                let number = String(address[Range(match.range(at: 2), in: address)!])
                let supplement = String(address[Range(match.range(at: 3), in: address)!])
                let postalCode = String(address[Range(match.range(at: 4), in: address)!])
                let city = String(address[Range(match.range(at: 5), in: address)!])
                
                result.append(street)
                result.append(number)
                result.append(supplement)
                result.append(postalCode)
                result.append(city)
            }
            
        } catch {
            print("Invalid pattern: \(error.localizedDescription)")
            
        }
        return (!result[0].isEmpty && !result[1].isEmpty && !result[3].isEmpty && !result[4].isEmpty) ? true : false
    }
    
    //Function to check if the current command is valid
    /*func Valide_Current_Command() -> Bool{
        // A command is valid if :
        // the cart is not empty
        // the recover date is present and correct (with no weekends)
        // the shipping date is present and correct
        // The adress user has been correctly entered
        //Check conditons
        if self.cart.isEmpty{
            return false
        }
        if self.currentCommand.enter_date == Date().mySQLFormat()
        {
            return false
        }
        if self.currentCommand.return_date == Date().mySQLFormat(){
            return false
        }
        if !self.Validate_Adress(address: self.currentUser.adress){
            return false
        }
        
        return true
    }
    */
    
    //SERVICES
    //@Published var all_services:[Int:SERVICE]=[:]
    @Published var services_images:[String:UIImage] = [:]
}


//User settings
final class CurrentCommand:ObservableObject{
    
    
    
    
}


// ======================================= Class des methodes qui communiquent avec la BD ===================================================
class FetchModels:ObservableObject{
    @Published var connection_process:Bool = false
    @Published var service_has_commands:[SERVICE_HAS_COMMAND] = []
    @Published var connectionComfirmation:Bool=false
    @Published var users:[User] = []
    @Published var times:[TIMES] = []
    @Published var commands:[Command] = []
    @Published var servicetemp:[Service] = []
    @Published var services:[Service] = []
    @Published var all_services:[Int:Service] = [:]
    @Published var newservice:[Service] = []
    @Published var connected:String = "false"
    @EnvironmentObject var userdata:UserData
    @StateObject var userfetchData = UserData()
    @Published var services_Images:[String:UIImage]=[:]
    @Published var coupons:[Coupon] = []
    //user commands
    @Published var userCommands:[Command] = []
    //Available works hours
    @Published var TIMES_IN_AVAILABLES:[Int]=[]
    @Published var TIMES_OUT_AVAILABLES:[Int]=[]
    
    @Published var services_ready:Bool = false
    //settings
    @Published var settings = Settings()
    
    @Published var loading:Bool = false
    
    //Command to review
    @Published var command_to_review:Command = Command()
    
    //User to review
    @Published var user_to_review:User = User()
    
    //Cart to review
    @Published var cart_to_review:[Service:Int] = [:]
    
    @Published var notif_text:String="test"
    //Récupérer tous les services associé à une commande, ainsi que les quantités
    func Fetch_Command_Service()async{
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getserviceandcommand?id=\(self.command_to_review.id)") else{
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
                let serviceHasCommands = try JSONDecoder().decode([command_service].self, from: data)
                print(serviceHasCommands)
                DispatchQueue.main.async {
                   // Command.cart = serviceHasCommands
                }
            }catch{
                print (error)
            }
        }
        task.resume()
    }
    
    
    //Get availables hours according to the day
    ///Function to revover for a date as String in MySQL format YYYY/MM/EE, the availables times
    func FetchTimes(day:String) async -> [Int]{
        var result:[Int]=[]
        
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getavailablehours?date=\(day)") else{
            return result
        }
        do{
            let (data,_) = try await URLSession.shared.data(from:url)
            if let decodedResponse = try? JSONDecoder().decode([Int].self, from: data){
                return decodedResponse
            }
        }catch{
            print("Error when fetching times")
        }
        return result
    }
   
    //Fonction qui prend un ID et renvoie un article correspondant
    func GetNameByID(sewingid:Int) -> Service{
        var name = Service.init()
        services.forEach { index in
            if index.id == sewingid {
                name = index
            }
        }
        return name
    }
    
    //Fonction qui renvoie un serviceHasCommand en fonction du numéro de commande
    func GetServiceInServiceHasCommand(id:Int64) -> [SERVICE_HAS_COMMAND]{
        var serviceToGive:[SERVICE_HAS_COMMAND] = []
        service_has_commands.forEach { index in
            if index.command_id == id{
                serviceToGive.append(index)
            }
        }
        return serviceToGive
    }
    
    
    
    //Fonction qui renvoie la desciprtion d'un service
    func GetServiceMessage() -> [String:String]{
        var response = [String:String]()
        
        services.forEach { index in
            response.updateValue(index.description, forKey: index.categories)
        }
        print(response)
        return response
    }
    
    //Fonction qui prend un ID et renvoie le client
    func getUserName(id:Int) -> User {
        var user:User = User.init()
        print("fetch Users")
        print(users.count)
        users.forEach { index in
            if index.id == id{
                user = index
            }
            
        }
        return user
    }
    
    func Pass(){
        self.connection_process = true
    }
    
    //fetch settings
    func fetchSettings(){
        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getsettings") else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){ [weak self]
            data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let set = try JSONDecoder().decode([Settings].self, from: data)
                
                DispatchQueue.main.async {
                    self?.settings = set[0]
                }
            }catch{
                print (error)
            }
        }
        task.resume()
    }
    
    
    
    
    //Fonction qui prend une liste de service et la join à une commande BD
    func PushServiceHasCommand(service:[SERVICE_HAS_COMMAND] , commandID:Int64) async {
        print("\(service.count.formatted())")
        
        //Pour chaque entrée de service has command on en crée une dans la BD
        service.forEach { index in
            //Ici on lance la fonction pour l'ajouter à la BD
            Task{
                PushSubServiceHasCommand(service: index, commandID: commandID)
            }
            
        }
    }
    
    //Fonction qui poste un service has command dans la BD
    func PushSubServiceHasCommand(service: SERVICE_HAS_COMMAND, commandID:Int64){
        guard let encoded = try? JSONEncoder().encode(service) else{
            print("Impossible d'encoder l'utilisateur ")
            return
        }
        let url = URL(string: "http://\(urlServer):\(urlPort)/addservicehascommand?service=\(service.service_ID_SERVICE)&command=\(commandID)&quantity=\(service.quantity)")!
        
        let task2 = URLSession.shared.dataTask(with: url)
        
        
        task2.resume()
    }

    //Fonction qui prend un nom et renvoie le tableau de tous les services associés à la catégorie
    func getServices(category:String) -> [Service]{
        var allServices:[Service] = []
        services.forEach { index in
            if index.categories.contains(category){
                allServices.append(index)
            }else
            if(category == "" ){
                allServices.append(index)
            }
        }
        
        return allServices
    }
    
 
    //Fonction qui tri le tableau des horaires en fonction du jour selectionné
    func GetTimesFromTIME(date:Date) -> [TIMES]{
        var result:[TIMES] = []
        print(date.formatDate())
        times.forEach { time in
            if time.day == date.formatDate(){
                result.append(time)
            }
        }
        return result
    }
    
    //Function to find an user according to his ID in the users list
    func GetUser_by_ID(id:Int32) -> User{
        return users.first(where: {$0.id == id})!
    }

    
    //Fonction qui cherche un utilisateur par son nom
    func SortUsers(a:String) -> [User]{
        var result:[User] = []
        
        //On cherche les utilisateurs dont le nom comporte a
        users.forEach { index in
            if index.name.capitalized.contains(a) || index.name.capitalized.contains(a.capitalized){
                result.append(index)
            }
        }
        return result
    }
    
    //Fonction qui renvoie Vrai si une Date existe en entrée
    func DateInExist(date:Date) -> Bool{
        var result:Bool = false
        commands.forEach { index in
            if index.enter_date == date.mySQLFormat(){
                result = true
            }
        }
        return result
    }
    
    //Fontion qui renvoi vrai si un creneau est disponible à une date
    func CheckTime(creneau:String, day:Date)  -> Bool{
        var result:Bool = true
        self.times.forEach { TIMES in
            print(TIMES.creneau)
            print(day.mySQLFormat())
            print(TIMES.state)
            if TIMES.creneau == creneau && day.formatDate() == TIMES.day && TIMES.state == 0{
                result = false
            }
        }
        return result
    }
    
   
    //Fonction qui récupère la liste des employés parmis la liste des utilisateurs
    func GetEmployees() -> [User]{
        var result:[User] = []
        users.forEach { index in
            if index.type == "Agent"{
                result.append(index)
            }
        }
        return result
    }
    
    //Function to add days to a given date
    func AddDaysToDate(date:Date, daysToAdd:Int)->Date{
        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: date)!
    }
    
    

    //Function to sort commands with the same hour. We take a Date and return a dictionnary [hour-less : [commands]]
    func Commands_Hours_Dict(date:Date) -> [Int:[Command]]{
        var result:[Int:[Command]] = [:]
        //Initialization. We want to always show all hours
        for a in 8...22{
            result[a] = []
        }
        //Now wa have it, we can add commands of the date
        
        for command in commands.filter({$0.enter_date == date.mySQLFormat()}) {
            result[Int(command.enter_time)!]?.append(command)
        }
        for command in commands.filter({$0.return_date == date.mySQLFormat()}) {
            result[Int(command.return_time)!]?.append(command)
        }
        return result
    }
    
    

    
    
    //format address to database format
    func Concat_Adress(adress:String, number:String, ext:String, postal_code:String, city:String)->String{
        
        return [adress,number,ext,postal_code,city].joined(separator: " ")
    }
    //format adress from database format
    func Uncat_Adress(address:String)->[String]{
        //(.+?) : le nom de la rue ou de l'avenue, qui peut contenir des espaces ;
        //(\d+[a-z]?) : le numéro de la maison, qui peut contenir une lettre optionnelle à la fin ;
        //(.*) : le supplément éventuel (par exemple, "bte 4"), qui peut contenir des espaces ;
        //(\d{4}) : le code postal, qui doit comporter exactement 4 chiffres ;
        //(.+) : le nom de la ville, qui peut contenir des espaces.
        var result:[String] = []
        let pattern = #"^(.+?)\s+(\d+[a-z]?)\s*(.*?)\s*(\d{4})\s+(.+)$"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            if let match = regex.firstMatch(in: address, range: NSRange(address.startIndex..., in: address)) {
                let street = String(address[Range(match.range(at: 1), in: address)!])
                let number = String(address[Range(match.range(at: 2), in: address)!])
                let supplement = String(address[Range(match.range(at: 3), in: address)!])
                let postalCode = String(address[Range(match.range(at: 4), in: address)!])
                let city = String(address[Range(match.range(at: 5), in: address)!])
                
                result.append(street)
                result.append(number)
                result.append(supplement)
                result.append(postalCode)
                result.append(city)
            }
            
        } catch {
            print("Invalid pattern: \(error.localizedDescription)")
            
        }
        return result
    }

    func Message_to_Cart_review(message:String)async -> [Service:Int]{
        var result_list:[Service:Int]=[:]
        print("Decode Message from command")
        if message.isEmpty{
            return [:]
        }
        if message.contains(","){
            for element in message.split(separator: ","){
                print(element)
                let serviceID = Int(element.split(separator: ":")[0])!
                let quantity = Int(element.split(separator: ":")[1])!
                result_list[self.all_services[serviceID]!] = Int(exactly: quantity)!
            }
        }else{ //no comma, then we have only one article
            let serviceID = Int(message.split(separator: ":")[0])!
            let quantity = Int(message.split(separator: ":")[1])!
            result_list.updateValue(quantity, forKey: self.all_services[serviceID]!)
        }
        return result_list
    }
    
    func Message_to_Cart_review_1(message:String)async->Bool{
        //var result_list:[SERVICE:Int]=[:]
        print("Decode Message from command")
        if message.isEmpty{
            return false
        }
        if message.contains(","){
            for element in message.split(separator: ","){
                print(element)
                let serviceID = Int(element.split(separator: ":")[0])!
                let quantity = Int(element.split(separator: ":")[1])!
                self.cart_to_review[self.all_services[serviceID]!] = Int(exactly: quantity)!
            }
        }else{ //no comma, then we have only one article
            let serviceID = Int(message.split(separator: ":")[0])!
            let quantity = Int(message.split(separator: ":")[1])!
            self.cart_to_review.updateValue(quantity, forKey: self.all_services[serviceID]!)
        }
        return true
    }
    
    
    //Reviews =========================================
    
    func GetData_from_command(command:Command)async{
        return self.command_to_review = command
    }
    
    
    func RemoveServiceFromCart_review(s:Service){
        if cart_to_review.contains(where: { T in
            T.key.id == s.id
        }){
            cart_to_review[s]! -= 1
            if (cart_to_review[s]! == 0){
                cart_to_review.removeValue(forKey: s)
            }
            //self.command_to_review.sub_total -= s.cost
        }
    }
    func AddServiceFromCart_review(s:Service){
        if cart_to_review.contains(where: { T in
            T.key.id == s.id
        }){
            cart_to_review[s]! += 1
            if (cart_to_review[s]! == 0){
                cart_to_review.updateValue(1, forKey: s)
            }
            //self.command_to_review.sub_total += s.cost
        }
    }
    
    
}

//====================== tests ======================
var testCommands:[Command]=[
    .init(user: 1, status: "Sent", cost: Decimal(2.99), dateIn: Date.now, message: "shoes:4, sac:2"),
    .init(user: 2, status: "Sent", cost: Decimal(20.99), dateIn: Date.now, message: "sac:2"),
    .init(user: 3, status: "Close", cost: Decimal(32.99), dateIn: Date.now, message: "shoes:4, sac:2, chemise:3"),
    .init(user: 4, status: "Close", cost: Decimal(32.99), dateIn: Date.now, message: "shoes:4, sac:2, chemise:3")
]


