//
//  Settings.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/06/2023.
//

import Foundation
enum session{
    case administrator
    case user
}

class AppSettings:ObservableObject {
    @Published var show_logo:Bool = true
    @Published var logged:Bool = false
    @Published var networkIsOn = true
    @Published var loggedAs = session.user
    
    func connect(){
        self.logged = true
    }
    func disconnect(){
        self.logged = false
    }
}
