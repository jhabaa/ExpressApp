//
//  AdminView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 02/03/2022.
//

import SwiftUI

struct AdminView: View {
    @Namespace var namespace : Namespace.ID
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var days:Days
    @EnvironmentObject var coupon:Coupons
    
    @EnvironmentObject var article:Article
    @EnvironmentObject var alerte:Alerte
    //@Binding var showMenu:Bool
    @State  var searchEntry:String = ""
    @State var EditPage:Bool = true
    @State var showButton:Bool = false
    @State var userMenuAdmin:Bool = false
    @State var commandMenuAdmin:Bool = false
    @State var servicesMenuAdmin:Bool = false
    @State var allOpions:Bool = false
    @State var homePage:Bool = true
    @State var couponPage:Bool = false
    //@Environment(\.presentationMode) var presentationMode
    @State var gridLayout: [GridItem] = [ GridItem(.flexible()), GridItem(.flexible())]
    @State var userMenu:[String]=["Add User","Delete User","Update User"]
    @State var adminMenu:[String]=["Add Admin","Delete Admin","Update Admin"]
    @State var MenuCaption1:Text = Text("Gérez tous les utilisateurs, les commandes et services")
    @State var MenuCaption2:Text = Text("Organisez les commandes qui vous sont assignées")
    var body: some View {
    GeometryReader{ geo in
        TabView {
            CommandAllView().zIndex(4)
                .tabItem {
                    Label("Commands", systemImage: "cart.fill")
                }
            
            UserAllView()
                .edgesIgnoringSafeArea(.top)
                .tabItem {
                    Label("Users", systemImage: "person.fill")
                }
                .onAppear(perform: {
                    utilisateur.fetch()
                })
                
            
            ServicesAllView()
                .tabItem {
                    Label("Services", systemImage: "server.rack")
                }
            
            CouponsView()
                .tabItem {
                    Label("Promos", systemImage: "button.programmable")
                }
                .tint(.blue)
               
            _SettingsView()
                .tabItem{
                    Label("Reglages", systemImage: "gear")
                }
            /*
            DateManagementView()
                .tabItem{
                    Label("Calendrier", systemImage: "calendar")
                }
            */
        }
        
        .tint(Color("xpress"))


    }
    .background(.linearGradient(colors: [.clear.opacity(0),.blue.opacity(0.3),.blue.opacity(0.4)], startPoint: UnitPoint.topLeading, endPoint: UnitPoint.bottomTrailing))
    

    }
}



struct Previews_AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
            .environmentObject(UserData())
            .environmentObject(Utilisateur())
            .environmentObject(Commande())
            .environmentObject(Days())
            .environmentObject(Coupons())
            .environmentObject(Alerte())
            .environmentObject(Article())
    }
}
