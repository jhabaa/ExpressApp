//
//  UserView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 19/02/2023.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var userdata:UserData
    var body: some View {
        GeometryReader {
            var size = $0.size
            
            if(userdata.pages[userdata.GetPage(page: "accueil")] == true){
                
                HomeView()
                
                    .onAppear{
                        userdata.taskbar = true
                    }
            }
            if(userdata.pages[userdata.GetPage(page: "profil")] == true){
                AccountView()
                /*
                    .onAppear{
                        userdata.taskbar = true
                    }*/
            }
            if(userdata.pages[userdata.GetPage(page: "panier")] == true){
                Cart()
                /*
                    .onAppear{
                        userdata.taskbar = false
                    }*/
            }
        }
        .onChange(of: userdata.IsActive(pagName: "accueil")) { newValue in
            print("change")
        }
    }
    
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        UserView().environmentObject(userData)
    }
}
