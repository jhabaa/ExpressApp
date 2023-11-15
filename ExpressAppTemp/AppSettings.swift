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
    case none // User is disconnected
}

class AppSettings:ObservableObject {
    @Published var show_logo:Bool = true
    /// Publish an alert if this turns true.
    @Published var connection_error = false
    /// Variable to show or not the loading view and hidding all other content
    @Published var loading:Bool = false
    /// Set the current session to show according to the session enumeration. This can be .administrator or .user
    @Published var loggedAs = session.none
    
    /// Connect the current user to the interface
    func connect(_ connectionMode:String){
        self.loggedAs = connectionMode == "user" ? .user : connectionMode == "admin" ? .administrator : .none //Check if connected user is user or admin otherwise set to none for security reason
    }
    /// Disconnect the current user from the interface
    func disconnect(){
        self.loggedAs = .none
    }
    func to_admin(){
        self.loggedAs = .administrator
    }
    func to_user(){
        self.loggedAs = .user
    }
}
