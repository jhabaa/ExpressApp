//
//  panier.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 29/06/2023.
//

import Foundation

class Panier:ObservableObject{
    @Published var services:Set<Achat>=[]
    @Published var command:Command=Command()
    
    /// Return the total amount of a cart
    var getCost:Decimal{
        var r:Decimal=Decimal()
        services.forEach {
            r += $0.price
        }
        return r
    }
    
    /// Return the number of articles in the cart
    var getNumberOfArticles:Int{
        var r:Int=Int()
        self.services.forEach {
            r += $0.quantity
        }
        return r
    }
    
    ///Clean cart
    func erase(){
        services.removeAll()
    }
    
    /// Return true if the cart is empty
    var isEmpty:Bool{
        return services.isEmpty
    }
    
    /// Cart to string
    var CartToString:String{
        var r:[String]=[]
        self.services.forEach {
            r.append("\($0.service.id):\($0.quantity)")
        }
        return r.joined(separator: ",")
    }
    
    ///Add article to the cart
    func toCart(_ achat:Achat){
        services.update(with: achat)
    }
    
    ///Increase element in the cart
    func increase(_ achat:Achat){
        services.remove(achat)
        print(services)
        services.insert(achat.increase())
        print(services)
    }
    
    ///Remove one element from the cart
    func decrease(_ achat:Achat){
        services.remove(achat)
        services.insert(achat.decrease())
        print(services)
    }
    
    ///Remove Element from cart
    func remove(_ s:Achat){
        services.remove(s)
    }
    ///Get quantity of an article in cart
    func getQuantityOf(_ s:Service)->Int{
        return self.services.filter({$0.service == s}).first?.quantity ?? 0
    }
    
    //function to get the minimum days to wait for a command according to the card
    func daysNeeded()->Int{
        let t = self.services.sorted(by: {$0.service.time > $1.service.time})
        
        return (t.isEmpty ? 3 : t.first!.service.time)
    }
}
