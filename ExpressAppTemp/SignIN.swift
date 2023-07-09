//
//  SignIN.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/05/2023.
//

import SwiftUI
import MapKit
enum user_field{
    case username, password, v_password
}

enum BelgianCity{
    case Bruxelles, Flandre, Wallonie , unset
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}

struct SignIN: View {
    @Namespace var namespace
    @EnvironmentObject var fetchModels:FetchModels
    @StateObject private var focusState = focusObjects()
    @EnvironmentObject var utilisateur:Utilisateur
    @State private var page:SignIn_pages = SignIn_pages()
    @EnvironmentObject var userdata:UserData
    @State var v_password:String = String()
    @Binding var _show:Bool
    @State var is_valid:Bool = false
    @State var primary_infos:Bool=false
    @State var adress_entry_view:Bool = false
    var body: some View {
        GeometryReader { _ in
            //Fond d'écran
            ZStack (alignment: .center, content: {
                Rectangle().fill(.clear).colorInvert()
                
            })
            .background(.bar)
            .background(
                ZStack(content: {
                    Circle()
                        .fill(Color("xpress"))
                        .blur(radius: 70)
                        .offset(x:100,y:300)
                        
                        .animation(.pulse(), value: true)
                    Rectangle()
                        .fill(.green)
                        .blur(radius: 60)
                        .frame(width: 100, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        .offset(x: -100, y: -200)
                })
                //Image(page.current!.introAssetImage)
                   // .resizable()
                    //.scaledToFill()
                
            )
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                //return all to false first
                withAnimation(.spring()){
                    focusState.focus_in.forEach { (key: String, value: Bool) in
                        focusState.focus_in.updateValue(false, forKey: key)
                    }
                }
            }
            
            //Adress view
            if primary_infos{
                AdressSelectorView(show: $_show)
            }else{
                ScrollView{
                    ExpressLogo()
                        .scaleEffect(1.3)
                        .animation(.spring(), value: _show)
                        .matchedGeometryEffect(id: "logo", in: namespace)
                        
                    Text(page.this.title)
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .padding(.top)
                        .minimumScaleFactor(0.4)
                        
                    Text(page.this.subTitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if page.current_index==1{
                        CustomTextField(_text: $utilisateur.this.name, _element: "utilisateur",hideMode:false, type:.text, name:"Nom d'utilisateur")
                            .padding(.horizontal)
                            
                        CustomTextField(_text: $utilisateur.this.surname, _element: "prenom",hideMode:false,type:.text, name:"Prenom d'utilisateur")
                            .padding()
                        
                        Spacer()
                        //Next Button
                        validationBtn(utilisateur.this.name.isEmpty)
                    }
                    
                    
                    
                    if page.current_index==2{
                        CustomTextField(_text: $utilisateur.this.phone, _element: "gsm",hideMode:false, type: .phone)
                        CustomTextField(_text: $utilisateur.this.mail, _element: "email",hideMode:false,type:.text, name:"@Email")
                            .textCase(.lowercase)
                            .textContentType(.emailAddress)
                        validationBtn((!utilisateur.this.isMailIsCorrect && !utilisateur.this.isValidBelgianGSM))
                    }
                    
                    if page.current_index == 3{
                        CustomTextField(_text: $utilisateur.this.password, _element: "mot de passe",hideMode:false,type:.password, name:"Mot de passe")
                        CustomTextField(_text: $v_password, _element: "v-mot de passe",hideMode:false,type:.password, name:"Entrez à nouveau")
                        
                         validationBtn(!(utilisateur.this.password == v_password && !utilisateur.this.password.isEmpty))
                    }
                        
                   
                    
                }
                
                .ignoresSafeArea(.keyboard)
                
                //return or prev
                Text(page.current_index == 1 ? "Annuler" : "Retour")
                    .underline()
                    .padding()
                    .onTapGesture {
                        withAnimation(.spring()){
                            if page.current_index == 1{
                                //Annuler
                                //userdata.currentUser = User()
                                utilisateur.this = User()
                                _show = false
                            }else{
                                page.prev()
                            }
                        }
                    }
            }
            
        }
        .autocorrectionDisabled()
        .environmentObject(focusState)
        //On change
        
        .onAppear {
            utilisateur.this = User()
        }
        
        
    }
    @State var place: IdentifiablePlace = .init(lat: 50, long: 50)
    @State var loading:Bool = false
    
    //validation Button
    @ViewBuilder
    func validationBtn(_ hide:Bool? = true, _ last:Bool? = false) -> some View{
        GeometryReader {
            var s = $0.size
            VStack(alignment:.center){
                Button {
                    //return all to false first
                    focusState.focus_in.forEach { (key: String, value: Bool) in
                        focusState.focus_in.updateValue(false, forKey: key)
                    }
                    
                    if page.current_index < page.pages.count{
                        //show next
                        withAnimation(.spring()) {
                            page.next()
                        }
                    }else{
                        //validate form
                        Task{
                            do{
                                userdata.loading = true
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)){}
                                primary_infos = (await utilisateur.register())
                                
                                print("Primary infos \(primary_infos)")
                                
                                //await fetchModels.FetchServices()
                                userdata.loading = false

                                //await userdata.Retrieve_commands(userdata.currentUser)
                                
                                /*
                                await UserData.save(user: userdata.currentUser, completion: {_ in
                                })
                                */
                            }catch{
                                print("Erreur d'ajout utilisateur")
                            }
                        }
                    }
                } label: {
                    if page.current_index < page.pages.count{
                        Label("Suivant", systemImage:"arrow.right.circle")
                            .padding()
                    }else{
                        Label("C'est Parti !", systemImage:"arrow.down.circle")
                            .padding()
                    }
                }
                .frame(width: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(Color("xpress"))
                .disabled((hide ?? false))
            }
            .frame(width: s.width)
            .scaleEffect(hide ?? true ? 0 : 1)
            
            .animation(.spring, value: hide)
        }
        
    }
        
        
}

struct SignIN_Previews: PreviewProvider {
    static var previews: some View {
        SignIN( _show: .constant(true), place: IdentifiablePlace(lat: 50.7069, long: 4.37539)).environmentObject(UserData())
            .environmentObject(Utilisateur())
    }
}
