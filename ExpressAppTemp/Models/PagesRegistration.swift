//
//  PagesRegistration.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 02/04/2023.
//

import SwiftUI

struct PageRegistration:Identifiable, Hashable {
    var id: UUID = .init()
    var introAssetImage: String
    var title:String
    var subTitle:String
    var displaysAction:Bool = false
}
struct SignIn_pages{
    var current_index:Int = 1
    var current:PageRegistration?
    var pages:[Int:PageRegistration] = [
        1:.init(introAssetImage: "page 1", title: "Enregistez vous\nChez Express", subTitle: "Pour commencer, choisissez un nom et un mot de passe"),
        2:.init(introAssetImage: "page 3", title: "Informations de contact", subTitle: "Veuillez entrer une adresse mail et un numéro de GSM valide"),
        3:.init(introAssetImage: "page 4", title: "Une dernière petite chose", subTitle: "Choisissez un mot de passe", displaysAction: true)
    ]
    init() {
        self.current = self.pages[current_index]!
    }
    
    mutating func next(){
        current_index += current_index < pages.count ? 1 : 0
    }
    mutating func prev(){
        current_index -= current_index > 1 ? 1 : 0
    }
    var this:PageRegistration{
        return self.pages[self.current_index]!
    }
}
var pagesRegistration:[PageRegistration]=[
    .init(introAssetImage: "page 1", title: "Enregistez vous\nChez Express", subTitle: "Pour commencer, choisissez un nom et un mot de passe"),
    .init(introAssetImage: "page 2", title: "Informations de livraison", subTitle: "Inscrivez votre adresse"),
    .init(introAssetImage: "page 3", title: "Informations de contact", subTitle: "Veuillez entrer une adresse mail et un numéro de GSM valide", displaysAction: true)
]

// Function to move to the next page
func ToNextPage(currentPage:PageRegistration)->PageRegistration{
    // get the current page Index
    var currentPageIndex = pagesRegistration.firstIndex(of: currentPage)
    
    if (Int(currentPageIndex!) < pagesRegistration.count-1){
        return pagesRegistration[Int(currentPageIndex!) + 1]
    }
    return pagesRegistration[Int(currentPageIndex!)]
}

//function to return the preview page
func ToPrevPage(currentPage:PageRegistration) -> PageRegistration{
    var currentPageIndex = pagesRegistration.firstIndex(of: currentPage)
    
    if (Int(currentPageIndex!) > 0){
        return pagesRegistration[Int(currentPageIndex!) - 1]
    }
    return pagesRegistration[Int(currentPageIndex!)]
}
