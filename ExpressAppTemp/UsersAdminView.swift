//
//  UsersAdminView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 26/04/2022.
//

import SwiftUI

struct UsersAdminView: View {
    @StateObject var fetchModel = FetchModels()
    var body: some View {
        NavigationView{
            VStack{
                List(fetchModel.users, id: \.self){
                    user in
                    
                }.listStyle(.plain)
                
                
                
            }.onAppear(perform: {
                fetchModel.fetchUsers()
            })
            .navigationTitle("User").navigationBarTitleDisplayMode(.automatic)
        }.navigationViewStyle(.stack)
    }
}

struct UsersAdminView_Previews: PreviewProvider {
    static var previews: some View {
        UsersAdminView()
    }
}
