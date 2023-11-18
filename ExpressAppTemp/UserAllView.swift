//
//  UserAllView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 21/03/2023.
//

import SwiftUI

struct UserAllView: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var alerte:Alerte
    @State var searchText:String=String.init()

    var body: some View {
        GeometryReader {
            _ in
            NavigationView {
                List(){
                    Section {
                        if !searchText.isEmpty{
                                withAnimation {
                                    Section{
                                        ForEach (utilisateur.all.sorted(by: {$0.id < $1.id}), id: \.self){ index in
                                            if(index.name.capitalized.contains(searchText)){
                                                NavigationLink {
                                                    UserDetailView(user:index)
                                                } label: {
                                                    HStack{
                                                        VStack{
                                                            HStack{
                                                                Text(index.name).font(.title2).bold()
                                                                Text(index.surname).font(.title3)
                                                                Spacer()
                                                            }
                                                            .foregroundStyle(.blue)
                                                            HStack{
                                                                Text("@\(index.id.formatted())").font(.caption)
                                                                Spacer()
                                                            }
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                            }
                                        }
                                    } header: {
                                        Text("Resultats de recherche")
                                    }.transition(.slide)
                                }
                            }
                           Text("Tous les utilisateurs")
                        }
                    Section{
                        ForEach(utilisateur.all.sorted(by: {$0.id < $1.id}), id: \.self){ u in
                            NavigationLink {
                                UserDetailView(user: u)
                            } label: {
                                HStack{
                                    VStack{
                                        HStack{
                                            Text(u.name).font(.title2).bold()
                                            Text(u.surname).font(.title3)
                                            Spacer()
                                        }
                                        VStack(alignment:.leading){
                                            Group {
                                                Text(u.phone)
                                                    .font(.caption)
                                                Text("@\(u.id.formatted())").font(.caption)
                                            }
                                            .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment:.leading)
                                    }
                                    Spacer()
                                }
                            }
                            //Swipe actions
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role:.destructive) {
                                    //Lets delete user
                                    Task{
                                        let response = await u.delete()
                                        if response{
                                            alerte.NewNotification(.amber, "L'utilisateur \(u.name) a été supprimé", UIImage(systemName: "person.fill.badge.minus"))
                                        }
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }.tint(.red)
                            }
                        }
                    }
                    
                    }
                .navigationTitle("Utilisateurs")
                
                //.edgesIgnoringSafeArea(.top)
            }
            
            //.ignoresSafeArea(.top)
            .background(.bar)
            .listStyle(.inset)
            .searchable(text: $searchText, prompt: Text("Rechercher un utilisateur"))
        }
        .onAppear{
            utilisateur.fetch()
        }
    }
}

struct UserAllView_Previews: PreviewProvider {
    static var previews: some View {
        UserAllView().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Utilisateur())
            .environmentObject(Alerte())
    }
}
