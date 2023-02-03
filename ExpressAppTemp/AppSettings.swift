//
//  Settings.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/06/2023.
//

import Foundation

class AppSettings:ObservableObject {
    @Published var show_logo:Bool = true
    @Published var logged:Bool = false
    
    func connect(){
        self.logged = true
    }
    func disconnect(){
        self.logged = false
    }
}
