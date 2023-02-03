//
//  AddUserView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 08/04/2022.
//

import SwiftUI


struct AddUserView: View {
    //@Binding var showAddUserview:Bool
    @State var showAddUserview:Bool = false
    @State var checked:Bool = false
    @State var errorMessage:Bool = false
    @State var connectionPass:Bool = false
    @State var stateText:String = ""
    @EnvironmentObject var fetchModel:FetchModels
   // @State var idUser:Int32
    @State var user:User = User.init()
    @State var nameUser:String = ""
    @State var surnameUser:String = ""
    @State var cityUser:String = ""
    @State var emailUser:String = ""
    @State var phoneUser:Int32 = Int32.zero
    @State var addressUser:String = ""
    @State var passwordUser:String  = ""
    @State var loggedUser:Int = Int.zero
    @State var typeUser:String = ""
    @State var passwordCheck:String = ""
    @State var page1:Bool = true
    @State var page2:Bool = false
    @State var page3:Bool = false
    @State var page4:Bool = false
    
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack{
                //Vue de formulaire
                VStack{
                    //header
                    ScrollView(Axis.Set.horizontal, showsIndicators: false, content: {
                        HStack{
                            
                            Button("Page1"){
                                withAnimation {
                                    page1 = true
                                    page2 = false
                                    page3 = false
                                    page4 = false
                                    
                                }
                                
                            }
                            Spacer()
                            Button("Page2"){
                                withAnimation {
                                    page1 = false
                                    page2 = true
                                    page3 = false
                                    page4 = false
                                    
                                }
                                
                            }
                            Spacer()
                            Button("Page3"){
                                withAnimation {
                                    page1 = false
                                    page2 = false
                                    page3 = true
                                    page4 = false
                                    
                                }
                                }
                            Spacer()
                            Button("Page4"){
                                withAnimation {
                                    page1 = false
                                    page2 = false
                                    page3 = false
                                    page4 = true
                                    
                                }
                                }
                        }
                    }).frame(width:GeometryProxy.size.width)
                    .padding(.top, 70)
                    .padding([.bottom, .leading])
                    .foregroundColor(.white)
                    .background(.blue)
                    Divider().padding()
                    
                    //Formulaire
                    if (page1){
                        //Informations utilisateur
                        VStack{
                           
                                
                            TextField("Name", text: $user.name).textFieldStyle(.plain).font(.title2)
                            Divider()
                            TextField("Surname", text: $user.surname).textFieldStyle(.plain).font(.title2)
                      
                
                            
                        }.padding()
                    }
                    if (page2){
                        VStack {
                            Section("Comment vous contacter ?") {
                                TextField("Email address", text: $user.mail).textContentType(.emailAddress).textFieldStyle(.plain).font(.title2)
                                Divider()
                                TextField("Phone Number", value: $user.phone, formatter: NumberFormatter()).keyboardType(.phonePad).textFieldStyle(.plain).font(.title2)
                            }.tabItem {}
                        }.padding().tabItem{}
                    }
                    if (page3){
                        VStack{
                            TextField("Address", text: $user.adress).textContentType(.fullStreetAddress).textFieldStyle(.roundedBorder)
                            //TextField("Postal Code", text: $user.CITY_USER).textFieldStyle(.roundedBorder)
                        }.padding()
                    }
                    if (page4){
                        VStack{
                            SecureField("Enter Password", text: $user.password).textContentType(.password).textFieldStyle(.roundedBorder).privacySensitive()
                            SecureField("Re-enter Password", text: $passwordCheck).border(.clear, width: 2).textContentType(.password).textFieldStyle(.roundedBorder).privacySensitive().foregroundColor(PassWordCheck(pass1: user.password, pass2: passwordCheck) ? .blue : .red)
                            #warning("A vérifier en cas de problème")
                                /*.onChange(of: passwordCheck) { newValue in
                                PassWordCheck(pass1: user.PASSWORD_USER, pass2: passwordCheck)
                            }*/
                            Divider()
                            if errorMessage{
                                Text("Les mots de passe ne correspondent pas")
                            }
                        }.padding()
                    }

                    //Formulaire

                    
                    Divider()
                    
                    
                    Button("S'inscrire"){
                        
                       // fetchModel.PushUser(user:user,connectionState: &connectionPass)
                        withAnimation(.spring()) {
                            showAddUserview.toggle()
                        }
                        
                        
                    }.buttonBorderShape(.capsule).padding().buttonStyle(.borderedProminent).disabled(!checked)
                            
                    Spacer()
                    
                }.frame(width: GeometryProxy.size.width).zIndex(1)
                
                //Button quitter
                VStack(alignment: HorizontalAlignment.center, spacing: 20) {
                    Spacer()
                    Button {
                        //Exit Code
                        withAnimation {
                            showAddUserview.toggle()
                        }
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill").resizable().frame(width: 50, height: 50)
                    }.tint(.red)
                }.zIndex(5)

            }.background(.thickMaterial)
            
        }.transition(.NewUserPage)
        
    }
    //Fonction qui vérifie que les deux mots de passes concordent
    func PassWordCheck(pass1:String, pass2:String) -> Bool{
        if pass1 == pass2{
            errorMessage = false
            checked = true
            return true
        }else{
            checked = false
            errorMessage = true
            return false
        }
        
            
    }

}


struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
    }
}
