//
//  SettingsView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//

import SwiftUI

struct AccountView: View{
    @Environment(\.editMode) private var editMode
    @State var dict:[String : Bool] = ["All":true, "Terminées":false, "Annulées":false]
    @State var notification:Bool = false
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var appSetting:AppSettings
    @State private var showCart:Bool = false
    @Namespace var namespace:Namespace.ID
    @State var logged:Bool = false
    @State var connectionView:Bool = false
    @State private var showAlert = false;
    @State private var showConnection = false;
    @State private var id:String = "hi";
    @State private var couponGrid: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @State var showSettings:Bool = false
    @State var showAll:[String:Bool] = [:]
    @State var offsetY:CGFloat = 0.0
    @State var currentIndex:CGFloat = 0
    @State var columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var selectedcommand:Command = Command.init()
    @State var showDetails_Command:Bool = false
    @State var modified_Command:Command = Command.init()
    @State var commadToView:Command=Command.init()
    @State var cart_to_review:[Service:Int] = [:]
    @State var show_all_commands:Bool = false
    @State var email_is_ok:Bool = false
    @State var adress_new:Bool = false
    @State var edit_mode:Bool = false
    var body: some View {
        GeometryReader(content: { GeometryProxy in
            NavigationView {
                List{
                    Section {
                        
                    } header: {
                        Text("Pour moi")
                    }
                footer:{
                    LazyHGrid(rows: [GridItem(.flexible(minimum: 100, maximum: 200))], alignment:.center) {
                        ForEach(userdata.options, id: \.self) { option in
                            NavigationLink {
                                if option.PageName == "Infos"{
                                    //UserDetailView(review_this: userdata.currentUser)
                                    UserDetailView(review_this: userdata.currentUser)
                                        .navigationTitle("Mon Compte")
                                        
                                }
                                if option.PageName == "Commandes"{
                                    DetailView1()
                                        .navigationTitle("Commandes")
                                }
                                if option.PageName == "Contacts"{
                                    Contacts()
                                        .navigationTitle("Nous contacter")
                                }
                            } label: {
                                Spacer()
                                VStack{
                                    Image(systemName: "\(option.PageIcon)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height:50)
                                    Text(option.PageName)
                                }
                                .padding(10)
                                .background(Material.ultraThick)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    }
                
                    //if admin
                    if userdata.currentUser.isAdmin{
                        Section {}header:{
                            VStack(alignment:.center){
                                Button("Mode Admin"){
                                    userdata.currentUser.type = "admin"
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.roundedRectangle(radius: 20))
                                .listItemTint(ListItemTint.fixed(Color.green))
                            }
                            .frame(maxWidth: .infinity)
                            
                        }
                    footer: {
                            Text("Vous migrerez vers une vue administrateur. Pour revenir à votre vue initiale, vous devrez dès lors vous deconnecter")
                                .font(.caption)
                        }
                    }
                

                    
                    Section{}
                header:{
                    Button {
                        withAnimation(.easeInOut) {
                            appSetting.disconnect()
                        }
                        //User.disconnect()
                    } label: {
                        VStack(alignment:.center){
                            Text("Deconnexion")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        
                    }
                }
                    
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Reglages")
            }
            if showDetails_Command{
                //Command_modifier(command_to_review: selectedcommand, cart_to_review: cart_to_review, show: $showDetails_Command)
                CommandDetailView(show_this: $showDetails_Command, _command: selectedcommand)
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .padding(.top, 50)
                            .padding(.leading, 20)
                            .colorMultiply(.accentColor)
                            .shadow(color: Color("fond"), radius: 10)
                            .onTapGesture {
                                //userdata.Back()
                                showDetails_Command.toggle()
                            }
                    }
            }
        })
        .background(.ultraThinMaterial)
        .background(.ultraThinMaterial)
        .onAppear{
            Task{
                //await fetchModel.FetchServices()
            }
        }
    }
    @ViewBuilder
    func Infos() -> some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 5){
                Text(userdata.currentUser.name)
                    .font(.custom("Ubuntu", size: 30))
                Text(userdata.currentUser.surname)
                    .font(.headline)
                Text("#\(userdata.currentUser.id)")
                
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Section {
                VStack{
                    //Email entry
                    TextField(text: $userdata.currentUser.mail) {
                        Label("Email", systemImage: "house")
                    }
                    //.disabled(!modifyMode)
                    .padding()
                    .background(.ultraThinMaterial)
                    .textContentType(UITextContentType.emailAddress)
                    .clipShape(Capsule())
                    .onChange(of: userdata.currentUser.mail) { V in
                        email_is_ok = userdata.CheckEmail()
                    }
                    
                }
                .disabled(edit_mode)
                .multilineTextAlignment(.center)
                
                TextField("Adresse de livraison",text: $userdata.currentUser.adress) {
                }
                .padding()
                .background(.ultraThinMaterial)
                .textContentType(UITextContentType.emailAddress)
                .clipShape(Capsule())
                .onChange(of: userdata.currentUser.adress) { V in
                    adress_new = userdata.CheckAddress()
                }
            } header: {
                Text("Vos informations de contacts sont utilisées lors de commandes pour estimer le cout d'un livraison ou en cas besoin relatif à une commande ")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()

            
        }
        .toolbar {
            EditButton()
                .onTapGesture {
                    edit_mode.toggle()
                }
        }
    }
    
    @ViewBuilder
    func DetailView1() -> some View{
        GeometryReader{ _ in
            NavigationView{
                //Cards
                List {
                    Section {
                        ForEach(userdata.user_commands.reversed(), id: \.self){ com in
                            /*3D cards
                             CardView(com:com)
                             .padding(.horizontal)*/
                            Text("#\(com.id)")
                            .badge("\(com.date_.toDate("mysql").dateUserfriendly())")
                                .onTapGesture {
                                    Task{
                                        selectedcommand = com
                                        showDetails_Command = true
                                        print("Message loaded")
                                    }
                                    
                                }
                            
                            
                        }
                    } header: {
                        VStack(alignment:.center){
                            Text("Commandes en cours")
                                .padding()
                        }.frame(maxWidth: .infinity)
                    }
                }
                .listStyle(.inset)
                /* 3D CARDS
                 .offset(y:offsetY)
                 .offset(y:currentIndex * -200.0)*/
            }
            .coordinateSpace(name: "SCROLL")
            .zIndex(10)
            //.frame(width: proxy.width, height: proxy.height)
        }
        //.coordinateSpace(name: "SCROLL")
        .background(.linearGradient(colors: [.black.opacity(0.9),.blue.opacity(0.1)], startPoint: .bottom, endPoint: .top))
        .onAppear{
            //fetchModel.fetchUserCommands(user: userdata.currentUser)
            Task{
                userdata.loading = true
                await userdata.Retrieve_commands(userdata.currentUser)
                selectedcommand = fetchModel.userCommands.reversed().first ?? Command.init()
                userdata.loading = false
                await cart_to_review = fetchModel.Message_to_Cart_review(message: selectedcommand.services_quantity)
            }
            
            //fetchModel.fetchSewing()
        }
        .onDisappear{
            userdata.taskbar = true
        }
        
    }
    
}



struct Previews_AccountView_Previews: PreviewProvider {
    @EnvironmentObject var userdata:UserData
    static var previews: some View {
        var oldcommand = UserData().user_commands
        AccountView().environmentObject(UserData())
            .environmentObject(FetchModels())
            .onAppear{
                Task{
                    oldcommand.append(Command(user: 1, status: "sent", cost: Decimal(2.3), dateIn: Date(), message: "2:3,4:6"))
                }
            }
        
    }
}
