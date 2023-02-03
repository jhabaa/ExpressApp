//
//  SignIN.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/05/2023.
//

import SwiftUI
enum user_field{
    case username, password, v_password
}

struct SignIN: View {
    @EnvironmentObject var fetchModels:FetchModels
    @StateObject private var focusState = focusObjects()
    @State private var page:SignIn_pages = SignIn_pages()
    @EnvironmentObject var userdata:UserData
    @State var v_password:String = String()
    //@FocusState private var user_focus:user_field?
    @State var _adress:[String]=["","","","",""]
    @Binding var _show:Bool
    @State var is_valid:Bool = false
    var body: some View {
        GeometryReader { _ in
            //Fond d'écran
            ZStack (alignment: .center, content: {
                Rectangle().fill(.linearGradient(colors: [Color("fond").opacity(0),
                                                          Color("fond").opacity(0.1),
                                                          Color("fond").opacity(0.3),
                                                          Color("fond").opacity(0.5),
                                                          Color("fond").opacity(0.7),
                                                          Color("fond").opacity(1),]
                                                 , startPoint: .top, endPoint: .bottom)).colorInvert()
                
            })
            .background{
                Image(page.current!.introAssetImage)
                    .resizable()
                    .scaledToFill()
                    
            }
            .ignoresSafeArea()
            .onTapGesture {
                //return all to false first
                withAnimation(.spring()){
                    focusState.focus_in.forEach { (key: String, value: Bool) in
                        focusState.focus_in.updateValue(false, forKey: key)
                    }
                }
            }
            //return or prev
            Text(page.current_index == 1 ? "Annuler" : "Retour")
                .underline()
                .padding()
                .onTapGesture {
                    withAnimation(.spring()){
                        if page.current_index == 1{
                            userdata.currentUser = User()
                            _show = false
                        }else{
                            page.prev()
                        }
                    }
                }
            VStack{
                Text(page.this.title)
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .padding(.top, 50)
                Text(page.this.subTitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if page.current_index==1{
                    CustomTextField(_text: $userdata.currentUser.name, _element: "username",type:.text)
                    CustomTextField(_text: $userdata.currentUser.surname, _element: "surname",type:.text)
                    CustomTextField(_text: $userdata.currentUser.password, _element: "password",type:.password)
                    CustomTextField(_text: $v_password, _element: "v_password",type:.password)
                }
                
                if page.current_index==2{
                    CustomTextField(_text: $_adress[0], _element: "road",type:.text)
                    CustomTextField(_text: $_adress[1], _element: "number",type:.text)
                    CustomTextField(_text: $_adress[2], _element: "sup",type:.text)
                    CustomTextField(_text: $_adress[3], _element: "postal code",type:.text)
                    CustomTextField(_text: $_adress[4], _element: "city",type:.text)
                    .onAppear{is_valid =  userdata.currentUser.readAdress(_adress)}
                }
                
                if page.current_index==3{
                    CustomTextField(_text: $userdata.currentUser.phone, _element: "phone", type: .phone)
                    CustomTextField(_text: $userdata.currentUser.mail, _element: "email",type:.text)
                }
                
                Spacer()
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
                                var r = !(await userdata.Register())
                                DispatchQueue.main.async {
                                    _show = r
                                }
                                await fetchModels.FetchServices()
                                userdata.loading = false

                                await userdata.Retrieve_commands(userdata.currentUser)
                                
                                
                                await UserData.save(user: userdata.currentUser, completion: {_ in
                                })
                                
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
                .buttonStyle(.borderedProminent)
                .tint(Color("xpress"))
                .disabled(!is_valid)
                
            }
        }
        .environmentObject(focusState)
        //On change
        .onChange(of: _adress) { _ in
            is_valid = userdata.currentUser.readAdress(_adress)
        }
        .onChange(of: v_password) { V in
            is_valid = userdata.currentUser.password == v_password && !userdata.currentUser.name.isEmpty
        }
        .onChange(of: userdata.currentUser.mail) { _ in
            is_valid = userdata.CheckEmail()
        }
    }
        
}

struct SignIN_Previews: PreviewProvider {
    static var previews: some View {
        SignIN( _show: .constant(true)).environmentObject(UserData())
    }
}
