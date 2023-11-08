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
    /// Publish an alert if this turns true.
    @Published var connection_error = false

    /// Variable to show or not the loading view and hidding all other content
    @Published var loading:Bool = false
    /// Set the current session to show according to the session enumeration. This can be .administrator or .user
    @Published var loggedAs = session.user
    
    /// Connect the current user to the interface
    func connect(){
        self.logged = true
    }
    /// Disconnect the current user from the interface
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
