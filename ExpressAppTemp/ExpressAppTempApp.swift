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
            let userdata = UserData()
            let fetchmodels = FetchModels()
            let settings = AppSettings()
            ContentView()
                .environmentObject(userdata)
                .environmentObject(fetchmodels)
                .environmentObject(settings)
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
