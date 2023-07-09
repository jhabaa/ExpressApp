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
    @Environment(\.presentationMode) var presentation
    @State var userToReview:User=User()
    @State var modifyMode:Bool = false
    @Namespace var namespace : Namespace.ID
    @StateObject private var focusState = focusObjects()
    let phoneFormatter: NumberFormatter = {
        let phoneFormatter = NumberFormatter()
        phoneFormatter.numberStyle = .none
    
        return phoneFormatter
    }()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    //=====================
    @State var orignal_user:User=User()
    @State var road=String()
    @State var number=String()
    @State var supplement=String()
    @State var postal=String()
    @State var city=String()
    @State var is_valid:Bool = false
    var body: some View {
    // Name and surname
    ScrollView{
        Text(utilisateur.review.name)
            .font(.custom("Coffeeandcrafts", size: 50, relativeTo: .largeTitle))
             Text(utilisateur.review.surname)
        if utilisateur.this.isAdmin{
            Text("@\(utilisateur.review.id)").font(.caption2).foregroundColor(.gray)
        }
        
        CustomTextField(_text: $utilisateur.review.mail, _element: "email",type:.text)
                .shadow(radius: 2)
                .padding(.vertical, 30)
        CustomTextField(_text: $utilisateur.review.phone, _element: "phone", type: .phone)
                .shadow(radius: 2)

        
        //Adress part
        Text("Adresse actuelle : \n\(utilisateur.review.adress)")
            .font(.caption)
            .foregroundColor(.gray)
        DisclosureGroup {
            //adress modifier
            
            CustomTextField(_text: $road, _element: "road", type:.text)
            CustomTextField(_text: $number, _element: "number", type:.text)
            CustomTextField(_text: $supplement, _element: "sup", type:.text)
            CustomTextField(_text: $postal, _element: "postal code", type:.text)
            CustomTextField(_text: $city, _element: "city", type:.text)
        } label: {
            Text("Nouvelle adresse")
                .padding()
                .foregroundColor(Color.primary)
                .background(.ultraThinMaterial)
                .cornerRadius(5)
        }
        .padding(.horizontal)

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .environmentObject(focusState)
    .autocorrectionDisabled(true)
    .onChange(of: [city, road, supplement, number, postal]) { _ in
        var response = utilisateur.review.readAdress([road,number,supplement,postal, city])
        
        if response{
            utilisateur.review.adress = [road,number,supplement,postal, city].joined(separator: " ").lowercased().replacingOccurrences(of: "  ", with: " ")
        }
        //is_valid = review_this.readAdress(adress)
        //print(is_valid)
    }
    .onTapGesture {
        //return all to false first
        withAnimation(.spring()){
            focusState.focus_in.forEach { (key: String, value: Bool) in
                focusState.focus_in.updateValue(false, forKey: key)
            }
        }
    }
    .onAppear{
        if utilisateur.this.isUser{
            utilisateur.review = utilisateur.this
        }else{
            utilisateur.review = userToReview
        }
        (road,number,supplement, postal, city) = utilisateur.review.get_adress_datas()
        
        //is_valid = true
    }
    .toolbar {
        
        if (utilisateur.review.readAdress([road,number,supplement,postal,city]) ){
            Button {
                //Edit button
                //toggle
                let handle = Task {
                    return await utilisateur.review.update()
                }
                if (utilisateur.this.isUser){
                    utilisateur.this = utilisateur.review
                }
                
                presentation.wrappedValue.dismiss()
            } label: {
                Text("Enregistrer")
                    .padding(5)
                    .cornerRadius(2)
            }
        }
    }
    /*VStack(spacing:0){
        /*
        //user address and tap quick destination
        Map(coordinateRegion: $region)
            .frame(width: size.width, height: 300)
            .opacity(0.8)
            .overlay {
                Rectangle().fill(.primary.opacity(0.5))
                    .overlay {
                        Text("Toucher pour aller à l'adresse")
                            .font(.title2)
                            .shadow(radius: 10)
                            .colorInvert()
                    }
            }
       
        */
        //user Infos to modify
        List {
            
            //header
            Section {
                
            } header: {
                VStack{
                    //user header
                    VStack(alignment:.center){
                        HStack(alignment: .center){
                            Image("afro")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .background(Circle().fill(.ultraThinMaterial))
                                .frame(width: 150, height: 150)
                            VStack(alignment:.leading){
                                Text(fetchmodel.user_to_review.name).font(.custom("Ubuntu", size: 30))
                                Text(fetchmodel.user_to_review.surname).font(.caption)
                            }
                        }.frame(width:size.width)
                            .padding()
                    }
                    TextField(text: $fetchmodel.user_to_review.mail) {
                        Label("Email", systemImage: "house")
                    }
                    .disabled(!modifyMode)
                    .badge("Email")
                    .padding()
                    .background(.ultraThinMaterial)
                    .textContentType(UITextContentType.emailAddress)
                    .clipShape(Capsule())
                    
                    
                    TextField(text: $fetchmodel.user_to_review.adress) {
                        Label("Adresse", systemImage: "location.fill")
                    }
                    .disabled(!modifyMode)
                    .badge("Adresse")
                    .padding()
                    .textContentType(UITextContentType.fullStreetAddress)
                    .background(.ultraThinMaterial)
                    .listStyle(.inset)
                    .clipShape(Capsule())
                    
                }
                .multilineTextAlignment(.center)
                .padding()
                .frame(width:size.width)
                .padding(.vertical, -50)
                .textCase(.lowercase)
                .zIndex(20)
                
            }

            //Commands
            Section {
                //User commands
                ForEach(fetchmodel.commands.reversed(), id: \.self){ com in
                    HStack{
                        Text("\(com.date_)")
                    }
                    .badge(com.cost.formatted(.currency(code: "EUR")))
                    .padding()
                }
            } header: {
                Label("Commandes", systemImage: "cart")
            }
            .onAppear{
                //fetchModel.fetchUserCommands(user: selectedUser)
                Task{
                    await userdata.Retrieve_commands(fetchmodel.user_to_review)
                }
            }
        }
        .listStyle(.sidebar)
        .listItemTint(.init("express"))
        .listRowSeparator(.hidden, edges: SwiftUI.VerticalEdge.Set.all)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.bottom)
        //.offset(y:-100)
        .zIndex(1)
    }
    .statusBarHidden(true)
    .ignoresSafeArea()
    .frame(width: size.width, height: size.height, alignment: Alignment.top)
        */
    }
}



struct Previews_UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Utilisateur())
    }
}
