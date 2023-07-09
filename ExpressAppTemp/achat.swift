//
//  achat.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 29/06/2023.
//

import Foundation

struct Achat:Hashable{
    
    var service:Service
    var quantity:Int
    
    var price:Decimal{
        return service.cost * Decimal(quantity)
    }
    
    init(quantity: Int) {
        self.service = Service()
        self.quantity = quantity
    }
    init(_ s:Service, _ q:Int){
        self.service = s
        self.quantity = q
    }
    
    func increase()->Achat{
        return Achat(service,quantity+1)
    }
    func decrease()->Achat{
        return Achat(service,quantity-1)
    }
}
