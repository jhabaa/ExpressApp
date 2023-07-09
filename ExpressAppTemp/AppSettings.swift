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
    @Published var connection_error = false
    @Published var loggedAs = session.user
    
    func connect(){
        self.logged = true
    }
    func disconnect(){
        self.logged = false
    }
    func to_admin(){
        self.loggedAs = .administrator
    }
    func to_user(){
        self.loggedAs = .user
    }
}
