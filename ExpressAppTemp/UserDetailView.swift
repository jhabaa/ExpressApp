//
//  UserDetailView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 08/05/2022.
//

import SwiftUI
import MapKit

struct UserDetailView: View {
    @EnvironmentObject var fetchmodel:FetchModels
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var alerte:Alerte
    @Environment(\.presentationMode) var presentation
    @State var user:User
    @State var adressChange:Bool = false
    @Namespace var namespace : Namespace.ID
    @StateObject private var focusState = focusObjects()
    let place: IdentifiablePlace = IdentifiablePlace(lat: 0.0, long: 0.0)
    let phoneFormatter: NumberFormatter = {
        let phoneFormatter = NumberFormatter()
        phoneFormatter.numberStyle = .none
    
        return phoneFormatter
    }()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    //=====================
    @State var orignal_user:User=User()
    @State var is_valid:Bool = false
    @State var viewThisCommand:Command=Command()
    @State var moreInfos:Bool=true
    var body: some View {
        ZStack{
            
            if !viewThisCommand.isNil{
                CommandInDetail(commande: $viewThisCommand, client: user)
                    .onAppear{
                        withAnimation {userdata.taskbar = false}
                    }
                    .onDisappear {
                        withAnimation {
                            Task{
                                await commande.fetchForuser(utilisateur.this)
                            }
                            userdata.taskbar = true
                        }
                    }
            }else{
                // Name and surname
                ScrollView(showsIndicators:false){
                    Map(coordinateRegion: .constant( MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(user.loc_lat), longitude: CLLocationDegrees(user.loc_lon)), latitudinalMeters: 300, longitudinalMeters: 300)),
                                annotationItems: [place])
                            { place in
                                MapPin(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(user.loc_lat), longitude: CLLocationDegrees(user.loc_lon)), tint: .green)
                            }
                        .disabled(true)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(.all)
                    Text(user.name)
                        .font(.custom("BebasNeue", size: 70, relativeTo: .largeTitle))
                        .lineLimit(2)
                        .minimumScaleFactor(0.4)
                        .overlay(alignment: .topTrailing) {
                            Text("\(user.isAdmin ? "administrateur":"")@\(user.id)").font(.caption2).foregroundColor(.gray)
                        }
                    
                    Text(user.surname)
                        .font(.custom("BebasNeue", size: 40, relativeTo: .largeTitle))
                        .lineLimit(2)
                        .minimumScaleFactor(0.4)
                        .offset(y:-20)
                    
                    DisclosureGroup(isExpanded:$moreInfos,
                        content: {
                            VStack(alignment:.leading, spacing: 10){
                                let isAdressIsEditable = user.isUser && (utilisateur.this.isAdmin || utilisateur.this.isUser)
                                let isCallable = utilisateur.this.isAdmin && user.isUser
                                HStack{
                                    
                                    Label("Adresse", systemImage: "location")
                                        .bold()
                                    //MARK: Here, admin can modify another adresses, but not his adress.
                                    //MARK: user can always modify his adress
                                    if (isAdressIsEditable){
                                        Text("modifier")
                                            .foregroundStyle(.gray)
                                            .underline()
                                    }
                                    
                                }
                                .onTapGesture {
                                    adressChange = true
                                }
                                .disabled(!isAdressIsEditable)

                                Text(user.adress)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                HStack{
                                    Label("GSM", systemImage: "phone")
                                        .bold()
                                   
                                    
                                }
                                if (isCallable){
                                    //  Clickable telphone number
                                    Link("\(user.phone)", destination: URL(string: "tel:\(user.phone)")!)
                                }else{
                                    Text(user.phone)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                               
                                Label("Adresse mail", systemImage: "mail")
                                    .bold()
                                Text(user.mail)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        },
                        label: { Text("Informations").font(.custom("BebasNeue", size: 50)) }
                    )
                    //MARK: User's commands
                    DisclosureGroup(
                        content: {
                            //MARK: All user's commands
                            VStack(alignment: .leading) {
                                ForEach(commande.all.reversed(), id:\.self) { myCommand in
                                    //Command
                                    VStack(alignment:.leading){
                                        Text(myCommand.date_)
                                            .font(.custom("Ubuntu", size: 20))
                                        Text("\(myCommand.services_quantity.filter({$0==","}).count + 1) articles - \(myCommand.cost.formatted(.number))€")
                                            .font(.custom("Ubuntu", size: 10))
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment:.leading)
                                    .onTapGesture {
                                        viewThisCommand = myCommand
                                    }
                                }
                                
                            }
                            .frame(maxWidth: .infinity, alignment:.leading)
                            
                        },
                        label: { Text(user.isAdmin ? "Commandes" : "Mes Commandes").font(.custom("BebasNeue", size: 50))}
                    )
                    
                    Contacts()
                   
                    Divider()
                        .padding(.bottom,300)
                }
                .task {
                    await commande.fetchForuser(user)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            //MARK: Address change view
            if adressChange{
                AdressSelectorView(user: user, show: $adressChange)
                    .onAppear(perform: {
                        userdata.taskbar = false
                    })
            }
        }
    
    .environmentObject(focusState)
    .autocorrectionDisabled(true)
    .onTapGesture {
        //return all to false first
        withAnimation(.spring()){
            focusState.focus_in.forEach { (key: String, value: Bool) in
                focusState.focus_in.updateValue(false, forKey: key)
            }
        }
    }
    .onChange(of: adressChange, perform: { value in
        if !value{
            userdata.taskbar = true
        }
    })
    .onAppear(perform: {
        userdata.taskbar = true
    })
    }
}



struct Previews_UserDetailView_Previews: PreviewProvider {
    static var previews: some View {

        UserDetailView(user: User(name: "John")).environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Utilisateur())
            .environmentObject(Commande())
            .environmentObject(Alerte())
    }
}
