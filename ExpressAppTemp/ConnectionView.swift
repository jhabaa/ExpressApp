//
//  ConnectionView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 17/02/2022.
//

import SwiftUI
import UIKit

/**
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

   var window: UIWindow?

   func application(_ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions:
                    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     FirebaseApp.configure()

     return true
   }
 }
 */


struct ConnectionView: View {
    enum FocusedField {
        case userName, password
    }
    //@FocusState private var focusedField: FocusedField?
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var fetchModels:FetchModels
    @EnvironmentObject var appSettings:AppSettings
    @StateObject private var focusState = focusObjects()
    @State var connectedState:Bool = false
    @State private var password = ""
    @State var userName:String = ""
    @Binding var connectionView:Bool
    @State var showLoading:Bool = false
    @Binding var showMenu:Bool
    @State var connectButton:Bool = false
    //@Environment(\.dismiss) var dismiss
    @State var notification:Bool = false
    @State var notificationtext:String = ""
    @Namespace var namespace : Namespace.ID
    //let saveAction: ()->Void
    
    var body: some View {
        
                VStack{
                    VStack{
                        //User ID
                        VStack{
                            HStack{
                                Image(systemName: "person").resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(.primary).padding().background(.thinMaterial)
                                    .clipShape(Circle())
                                CustomTextField(_text: $userdata.currentUser.name, _element: "username",type:.text)
                                    .shadow(color: Color("fond"), radius: 5)
                            }
                            
                            
                            //Password
                            HStack{
                                Image(systemName: "lock").resizable().scaledToFit().frame(width: 30, height: 30)
                                    .foregroundColor(.primary).padding().background(.thinMaterial)
                                    .clipShape(Circle())
                                CustomTextField(_text: $userdata.currentUser.password, _element: "password", type:.password)
                                    .shadow(color: Color("fond"), radius: 5)
                                    
                                   
                            }
                        }.font(.title3).padding(.horizontal)
                            .ignoresSafeArea(.keyboard, edges: Edge.Set.all)
                            .autocorrectionDisabled()
                        
                        //Mot de passe oublié
                        Button("Mot de passe oublié ?"){}
                            .padding()
                        
                        //Button
                        HStack(alignment: .center, spacing: 20){
                            //return button
                            Button(action: {
                                //return action
                                withAnimation(.easeInOut(duration: 0.5)){
                                    connectionView = false
                                }
                            }, label: {
                                Image(systemName: "arrow.backward.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .clipped()
                                    .frame(width: 50)
                                    .foregroundColor(.secondary)
                            })
                            //connexion button
                            Button {
                                Task {
                                    
                                    //userdata.loading = true
                                    
                                        // Connection with current user (init if unconnected with just username and password filled)
                                   
                                    
                                    let response = await userdata.Connect(user: userdata.currentUser)
                                    if response{
                                        print("connexion")
                                        appSettings.connect()
                                    }
                                    await fetchModels.FetchServices()
                                    await userdata.Retrieve_commands(userdata.currentUser)
                                }
                            } label: {
                                Text("Se Connecter").font(.system(size: 20)).padding()
                                    .foregroundColor(.primary)
                                    .background(Color("xpress"))
                                    .clipShape(Capsule())
                                
                                    .shadow(color: Color("fond"), radius: 5)
                            }
                        }
                       
                    }
                    .padding()
                }
                //.frame(maxHeight: .infinity, alignment: .center)
                //.padding()
                
                .padding()
                .onAppear(perform: {
                    withAnimation (.easeInOut(duration: 1.0)){
                        appSettings.show_logo  = false
                    }
                })
                .onDisappear(perform: {
                    withAnimation (.easeInOut(duration: 1.0)){
                        appSettings.show_logo  = true
                    }
                })
        .environmentObject(focusState)
        .onTapGesture {
            withAnimation (.spring()){
                focusState.focus_in.forEach { (key: String, value: Bool) in
                    focusState.focus_in.updateValue(false, forKey: key)
                }
            }
        }
    }
}


struct Previews_ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(connectionView: Binding.constant(true), showMenu: Binding.constant(true))
            .environmentObject(AppSettings())
            .environmentObject(UserData())
            .environmentObject(FetchModels())
    }
        
}
