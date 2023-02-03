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
    @State var review_this:User
    @State var adress:[String]=["","","","",""]
    @State var is_valid:Bool = false
    var body: some View {
    // Name and surname
    ScrollView{
        Text(review_this.name).font(.custom("Coffeeandcrafts", size: 50, relativeTo: .largeTitle))
        Text(review_this.surname)
        if userdata.currentUser.isAdmin{
            Text("@\(review_this.id)").font(.caption2).foregroundColor(.gray)
        }
        
        CustomTextField(_text: $review_this.mail, _element: "email",type:.text)
                .shadow(radius: 2)
                .padding(.vertical, 30)
            CustomTextField(_text: $review_this.phone, _element: "phone", type: .phone)
                .shadow(radius: 2)

        
        //Adress part
        Text("Adresse actuelle : \n\(review_this.adress)")
            .font(.caption)
            .foregroundColor(.gray)
        DisclosureGroup {
            //adress modifier
            
            CustomTextField(_text: $adress[0], _element: "road", type:.text)
            CustomTextField(_text: $adress[1], _element: "number", type:.text)
            CustomTextField(_text: $adress[2], _element: "sup", type:.text)
            CustomTextField(_text: $adress[3], _element: "postal code", type:.text)
            CustomTextField(_text: $adress[4], _element: "city", type:.text)
            .onAppear{is_valid =  review_this.readAdress(adress)}
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
    .onChange(of: adress) { _ in
        print(adress)
        is_valid = review_this.readAdress(adress)
        print(is_valid)
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
        // Create copy of the actual user
        orignal_user = review_this
        is_valid = true
    }
    .toolbar {
        if (is_valid && orignal_user != review_this){
            Button {
                //Edit button
                //toggle
                let handle = Task {
                    return await review_this.update()
                }
                if (userdata.currentUser.isUser){
                    userdata.currentUser = review_this
                }
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
        UserDetailView(review_this: User(name: "John")).environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}
