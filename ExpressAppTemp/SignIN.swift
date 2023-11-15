//
//  SignIN.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/05/2023.
//

import SwiftUI
import MapKit

enum signInStage {
case username, password, adress, contact
}

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
    enum focusEntry:Hashable{
        case username, usersurname, password, vpassword, GSM, mail
    }
    @Namespace var namespace
    @EnvironmentObject var fetchModels:FetchModels
    @EnvironmentObject var appSettings:AppSettings
    @Environment(\.colorScheme) var colorscheme
    @StateObject private var focusState = focusObjects()
    @EnvironmentObject var utilisateur:Utilisateur
    @State private var page:SignIn_pages = SignIn_pages()
    @EnvironmentObject var userdata:UserData
    @State var v_password:String = String()
    @Binding var _show:Bool
    @State var is_valid:Bool = false
    @State var primary_infos:Bool=false
    @State var adress_entry_view:Bool = false
    @State var stages:[signInStage] = [.username, .contact, .password, .adress]
    @State var stageIndex:Int = 0
    @State var stageIsValid:Bool = true
    @FocusState var focusOn:focusEntry?
    var body: some View {
        GeometryReader {
            //Fond d'écran
            RadialGradient(colors: [Color("xpress"), colorscheme == .dark ? .black : .white], center: .topLeading, startRadius: 100, endRadius: 800)
                .blur(radius: 100)
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
                AdressSelectorView(user: utilisateur.this, show: $_show)
            }else{
                ScrollView{
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.primary.opacity(0), Color.primary.opacity(1)], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 0.2)
                        .padding(.bottom, 70)
                    VStack(alignment:.leading){
                        Text(page.this.title)
                            .font(.custom("BebasNeue", size: 70))
                            //.fontWeight(.bold)
                            .padding(.top)
                            .minimumScaleFactor(0.4)
                            .shadow(radius: 4)
                        Text(page.this.subTitle)
                            .font(.custom("Ubuntu", size: 20))
                            
                    }
                    .frame(maxWidth: .infinity, alignment:.leading)
                    Spacer(minLength: 50)
                    
                    if page.current_index==1{
                        CustomTextField(_text: $utilisateur.this.name, _element: "utilisateur",hideMode:false, type:.text, name:"Nom d'utilisateur")
                            .focused($focusOn,equals: .username)
                            .submitLabel(.next)
                            .padding(.horizontal)
                            .ignoresSafeArea(.keyboard)
                            
                        CustomTextField(_text: $utilisateur.this.surname, _element: "prenom",hideMode:false,type:.text, name:"Prenom d'utilisateur")
                            .focused($focusOn,equals: .password)
                            .ignoresSafeArea(.keyboard)
                            .padding()
                            .submitLabel(.continue)
                        
                    }
                    if page.current_index==2{
                        CustomTextField(_text: $utilisateur.this.phone, _element: "gsm",hideMode:false, type: .phone)
                            .focused($focusOn,equals: .GSM)
                            .submitLabel(.next)
                            .ignoresSafeArea(.keyboard)
                            .keyboardType(.phonePad)
                           
                        CustomTextField(_text: $utilisateur.this.mail, _element: "email",hideMode:false,type:.text, name:"@Email")
                            .focused($focusOn,equals: .mail)
                            .textCase(.lowercase)
                            .textContentType(.emailAddress)
                            .ignoresSafeArea(.keyboard)
                            .submitLabel(.continue)
                    }
                    
                    if page.current_index == 3{
                        CustomTextField(_text: $utilisateur.this.password, _element: "mot de passe",hideMode:false,type:.password, name:"Mot de passe")
                            .focused($focusOn,equals: .password)
                            .ignoresSafeArea(.keyboard)
                            .submitLabel(.next)
                        CustomTextField(_text: $v_password, _element: "v-mot de passe",hideMode:false,type:.password, name:"Entrez à nouveau")
                            .focused($focusOn,equals: .vpassword)
                            .ignoresSafeArea(.keyboard)
                            .submitLabel(.done)
                    }
                }
                .ignoresSafeArea(.keyboard)
                .onSubmit {
                    switch focusOn {
                    case .username:
                        focusOn = .usersurname
                    case .usersurname:
                        if (!utilisateur.this.isEmpty && !utilisateur.this.surname.isEmpty){
                            stageIndex += 1
                            page.next()
                            focusOn = .GSM
                        }
                    case .password:
                        focusOn = .vpassword
                    case .vpassword:
                        if (utilisateur.this.password == v_password){
                            Task{
                                userdata.loading = true
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)){}
                                primary_infos = (await utilisateur.register())
                                //await fetchModels.FetchServices()
                                userdata.loading = false
                            }
                        }
                    case .GSM:
                        focusOn = .mail
                    case .mail:
                        focusOn = .password
                    case .none:
                        break
                    }
                }
                //return or prev
                HStack{
                    Image(systemName: page.current_index == 1 ? "xmark" : "chevron.backward")
                        .padding()
                        .background(.ultraThinMaterial)
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
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                //===============Algo ============
                //MARK: Show or not depending on the content
                
                //MARK: Register validation Button
                VStack(alignment:.center){
                    Button(action: {
                        switch stages[stageIndex] {
                        case .password:
                            Task{
                                userdata.loading = true
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)){}
                                primary_infos = (await utilisateur.register())
                                //await fetchModels.FetchServices()
                                userdata.loading = false
                            }
                        default:
                            withAnimation(.spring()) {
                                stageIndex += 1
                                page.next()
                            }
                        }
                    }, label: {
                        Text("Continuer")
                            .font(.title)
                            .padding(2)
                            .frame(maxWidth: .infinity)
                    })
                }
                .padding()
                .buttonBorderShape(.roundedRectangle(radius: 10))
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: $0.size.width, maxHeight: $0.size.height, alignment: .bottom)
                
                .scaleEffect(
                    StageIsValid() ? 1 : 0
                )
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
    
    func StageIsValid()->Bool{
        switch stages[stageIndex] {
        case .username:
            return !utilisateur.this.name.isEmpty
        case .password:
            return utilisateur.this.password == v_password
        case .adress:
            return false
        case .contact:
            return utilisateur.this.isMailIsCorrect && utilisateur.this.isValidBelgianGSM
        }
    }
}

struct SignIN_Previews: PreviewProvider {
    static var previews: some View {
        SignIN( _show: .constant(true), place: IdentifiablePlace(lat: 50.7069, long: 4.37539)).environmentObject(UserData())
            .environmentObject(Utilisateur())
            .environmentObject(AppSettings())
    }
}
