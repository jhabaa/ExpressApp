//
//  Params.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 25/10/2023.
//

import Foundation

class Params:Codable{
    var id:Int = Int()
    var tarif_bruxelles:Decimal = Decimal()
    var tarif_brabant:Decimal = Decimal()
    var tarif_km:Decimal = Decimal()
    
   
}


func RetrieveParameters()async -> Params?{
    guard let url = URL(string: "http://express.heanlab.com/getparams") else {
        print("Invalid URL")
        return nil
    }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let decodedResponse = try? JSONDecoder().decode([Params].self, from: data) {
            return decodedResponse.first!
        }
        // more code to come
    } catch {
        print("Invalid data")
    }
    return nil
}

func UpdateParameters(_ parameters : Params) async -> Bool {
    guard let encoded = try? JSONEncoder().encode(parameters) else{
        return false
    }
    let url = URL(string:"http://\(urlServer):\(urlPort)/updateparams")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-type")
    request.httpMethod = "POST"
    do{
        let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
        return true
    } catch{
        print("Upload impossible")
        return false
    }
}
