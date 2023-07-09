//
//  ExpressAppTempApp.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//

import SwiftUI

@main
struct ExpressAppTempApp: App {
 
    var body: some Scene {
        WindowGroup {
            var userdata = UserData()
            var fetchmodels = FetchModels()
            var settings = AppSettings()
            var panier = Panier()
            let article = Article()
            var coupon = Coupons()
            let utilisateur = Utilisateur()
            let commande = Commande()
            let alerte = Alerte()
            ContentView()
                .environmentObject(userdata)
                .environmentObject(fetchmodels)
                .environmentObject(settings)
                .environmentObject(panier)
                .environmentObject(article)
                .environmentObject(utilisateur)
                .environmentObject(coupon)
                .environmentObject(commande)
                .environmentObject(alerte)
                .onAppear {
                    /*
                    UserData.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                            
                        case .success(let user):
                            userdata.currentUser = user
                        }
                    }
                    
                    UserData.loadCommand(user_ID: userdata.currentUser.id) { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                            
                        case .success(let command):
                            userdata.currentCommand = command
                        }
                    }
                     */
                }
        }
        
    }
}
