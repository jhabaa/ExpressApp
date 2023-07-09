//
//  UsersAdminView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 26/04/2022.
//

import SwiftUI

struct UsersAdminView: View {
    //@StateObject var fetchModel = FetchModels()
    @EnvironmentObject var utilisateur:Utilisateur
    var body: some View {
        NavigationView{
            VStack{
                List(utilisateur.all.sorted(by: {$0.id < $1.id}), id: \.self){
                    user in
                    
                }.listStyle(.plain)
            }.onAppear(perform: {
                //fetchModel.fetchUsers()
                utilisateur.fetch()
            })
            .navigationTitle("User").navigationBarTitleDisplayMode(.automatic)
        }.navigationViewStyle(.stack)
    }
}

struct UsersAdminView_Previews: PreviewProvider {
    static var previews: some View {
        UsersAdminView()
            .environmentObject(Utilisateur())
    }
}
