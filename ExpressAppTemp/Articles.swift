//
//  Articles.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 01/07/2023.
//

import Foundation
import UIKit



struct Service:Hashable, Codable{
    static var services:[Service]=[]
    var id: Int
    var name:String
    var cost:Decimal
    var categories:String
    var time:Int
    var description:String
    var illustration:String
    init() {
        self.id = 3
        self.name = "Nom de l'article"
        self.cost = Decimal()
        self.categories = "Categorie"
        self.time = 3
        self.description = "Description de l'article"
        self.illustration =  "default"
    }
    
    //delete this service
    func Delete()async -> Bool{
        //Fonction qui supprime un service
        guard let encoded = try? JSONEncoder().encode(self) else{
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/deleteservice")!
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
    
    
    // Return true if a service isn't already there
    var is_acceptable:Bool{
       return !Service.services.contains { serv in
           serv.name == self.name
       } && self.name != "Nom de l'article" && self.categories != "categorie" && self.description != "Description de l'article"
    }
}

final class Article:ObservableObject{
    @Published var this:Service = Service()
    @Published var all:Set<Service> = []
    @Published var images:[String:UIImage] = [:]
    
    // FONCTIONS
    
    ///Function to get a Service by his ID
    func GetService(id:Int)->Service{
        return self.all.first(where: {$0.id == id}) ?? Service()
    }
    ///set service as this
    func set(_ service:Service)->Bool{
        self.this = service
        return true
    }
    
    func articleOutOfCart(_ services:Set<Achat>)->Set<Achat>{
        var t:Set<Achat> = Set(self.all.map({Achat($0, 0)}))
       /* return self.all.filter { s in
            !services.contains(where: {$0.service.id == s.id})
        }*/
        return t.subtracting(services)
    }
    
    
    /// function to get an Uimage from the server
    func getImage(_ service_name : String) async -> UIImage? {
        guard let imageURL = URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(service_name)") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            return UIImage(data: data)
        } catch {
            print("Error while fetching image: \(error.localizedDescription)")
            return UIImage(named: "logo120")
        }
    }

    /// Function to recover all services and Images of services
    func fetch() async {
        var t_services: Set<Service> = []
        var t_all_services: [Int:Service] = [:]
        var queue = DispatchQueue(label: "image_loading_queue") // Créer une file d'attente pour les modifications de t_all_images

        guard let url = URL(string: "http://\(urlServer):\(urlPort)/getservices") else {
            return
        }
        var data = Data()
        var url_response = URLResponse()
        do {
            (data, url_response) = try! await URLSession.shared.data(from: url)
            
            let services = try! JSONDecoder().decode(Set<Service>.self, from: data)

            services.forEach({ service in
                Service.services.append(service)
                t_services.insert(service)
                t_all_services[service.id] = service
                Task.detached(priority: .background) {
                    //Download illustration if doesnt exist here
                    if await !self.images.contains(where: {
                        $0.value == UIImage(named: service.illustration)
                    }){
                        let image = await self.getImage(service.illustration)
                        DispatchQueue.main.async {
                            self.images.updateValue(image! , forKey: service.illustration)
                        }
                    }
                    /*
                    if await !(self.images.contains(where: { (key: String, value: UIImage) in
                        key == service.illustration
                    })){
                        let image = await self.getImage(service.illustration)
                        DispatchQueue.main.async {
                            self.services_Images[service.illustration] = image
                        }
                    }*/
                }
            })

            DispatchQueue.main.sync {
                self.all = t_services
                //self.services_Images = t_all_images
                //self.services_ready = true
            }
        }

        return
    }
    
    
    func loadImage(_ image_to_send:UIImage?, _ illustration:String){
        if let imageData = image_to_send!.jpegData(compressionQuality: 1.0) {
                let url = URL(string: "http://\(urlServer):\(urlPort)/uploadimage") // replace with your server URL
                let session = URLSession.shared

                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                
                let boundary = UUID().uuidString
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(illustration).jpg\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                data.append(imageData)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                request.httpBody = data
                
            session.uploadTask(with: request, from: data, completionHandler: { Dataresponse, URLResponse, Error in
                if Error == nil{
                    let jsonData = try? JSONSerialization.jsonObject(with: Dataresponse!, options: .fragmentsAllowed)
                    if let json = jsonData as? [String:Any]{
                        print(json)
                    }
                }
            }).resume()
        }else{
            print("Zur")
        }
    }
    
    ///Fonction qui ajoute un service dans la BD
    func PushService(_ new_image:UIImage?)async -> Bool{
        print(self.this)
        guard let encoded = try? JSONEncoder().encode(self.this) else{
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/addservice")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            // Upload Image too
            loadImage(new_image ,self.this.illustration)
            print("Upload effectué")
            return true
        } catch{
            print("Upload impossible")
            return false
        }
    }
    
    ///Function  to update a service
    func Put_Service(service:Service) async -> Bool{
        guard let encoded = try? JSONEncoder().encode(service) else{
            print("erreur d'encodage")
            return false
        }
        let url = URL(string:"http://\(urlServer):\(urlPort)/updateservice")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        do{
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Updated Service")
            return true
        } catch{
            print("Upload impossible")
            return false
        }
    }
    
    
    
    //Fonction qui renvoie la liste de catérogies de services
    func GetCategories() -> Set<String>{
        var response = Set<String>()
        
        self.all.forEach { service in
            service.categories.split(separator: ";").forEach { el in
                response.insert(String(el))
            }
        }
        return response
    }
    

}
