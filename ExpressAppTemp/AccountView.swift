//
//  SettingsView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//

import SwiftUI
import MapKit
//Blob
let blob = Path{ path in
    path.move(to: CGPoint(x: 30, y: 50))
    path.addLine(to: CGPoint(x: 350, y: 0))
    path.addQuadCurve(to: CGPoint(x: 350, y: 50), control: CGPoint(x:400, y: 0))
    path.addLine(to: CGPoint(x: 350, y: 50))
    path.addQuadCurve(to: CGPoint(x: 70, y: 300), control: CGPoint(x:300, y: 400))
    path.addLine(to: CGPoint(x: 70, y: 300))
    path.addQuadCurve(to: CGPoint(x: 30, y: 50), control: CGPoint(x:100, y: 50))
}


struct AccountView: View{
    @Environment(\.editMode) private var editMode
    @Environment(\.colorScheme) var colorscheme
    @State var dict:[String : Bool] = ["All":true, "Terminées":false, "Annulées":false]
    @State var notification:Bool = false
    @StateObject private var focusState = focusObjects()
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var appSetting:AppSettings
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var article:Article
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
    @State var userToReview:User=User()
    @State var orignal_user:User=User()
    @State var road=String()
    @State var number=String()
    @State var supplement=String()
    @State var postal=String()
    @State var city=String()
    @State var is_valid:Bool = false
    @State var changeAdress:Bool = false
    @State var credits:Bool = false
    @State var show_options:Bool = false
    @State var show_delete_account = false
    @State var place: IdentifiablePlace = .init(lat: 50.87353, long: 4.48712)
    @State var show_this_command:Bool = false
    @State var commandToView:Command=Command()
    var body: some View {
        GeometryReader(content: { GeometryProxy in
            //values
            let s = GeometryProxy.size
            let frameY = GeometryProxy.frame(in: .named("scroll")).minY
            let minY = GeometryProxy.frame(in: .named("scroll")).minY + GeometryProxy.safeAreaInsets.top
           
            
            ScrollView(showsIndicators: false){
                let minY_Scroll = GeometryProxy.frame(in: .named("scroll")).minY
                //cover
                BackgroundFadeColor(s)
                    .ignoresSafeArea(.all)
                
                
                //MARK: Show user's card
                UserCard(user: utilisateur.this, width: s.width)
                    .padding(.top, 200)
               
                //Autres menus
                
                
                Contacts()
                
                //Old commands list
                DisclosureGroup(isExpanded: $showDetails_Command) {
                    //Commands list
                    Section {
                        ForEach(commande.all.reversed(), id: \.self){ com in
                            Button(action: {
                                Task{
                                    commandToView = com
                                    show_this_command = true
                                }
                            }, label: {
                                VStack(alignment:.leading){
                                    Text(com.date_)
                                        .foregroundStyle(.blue)
                                        .bold()
                                    HStack(alignment:.center){
                                        Text("\(com.cost.formatted(.currency(code:"EUR")))")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                        let c = com.services_quantity.filter({String($0) == ":"}).count
                                        Text("\(c) article\( c > 1 ? "s":"")")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(alignment: .leading)
                                }
                            })
                        }
                    }
                } label: {
                    Label("Mes commandes", systemImage: "timelapse")
                }
                .task {
                    await commande.fetchForuser(utilisateur.this)
                }
                .padding()
                Divider()
                    .padding(.bottom, 150)
            }
            .coordinateSpace(name: "scroll")
            .autocorrectionDisabled()
            .textInputAutocapitalization(TextInputAutocapitalization.never)
            .blur(radius: show_this_command ? 20 : 0, opaque: false)
            .ignoresSafeArea(.all)
            
            Button(action: {
                let handle = Task {
                    return await utilisateur.review.update()
                }
                if (utilisateur.this.isUser){
                    utilisateur.this = utilisateur.review
                }
            }, label: {
                Label("Enregistrer", systemImage: "square.and.arrow.down.on.square.fill")
            })
            .frame(width: GeometryProxy.size.width)
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.borderedProminent)
            .scaleEffect(y: (utilisateur.this != utilisateur.review && utilisateur.review.isMailIsCorrect) ? 1 : 0, anchor: .center)
            .animation(.spring, value: utilisateur.review)
            
                
            
            if show_options{
                VStack(spacing:100){
                    VStack(spacing:60){
                        Button {
                            //deconnect user
                            appSetting.to_admin()
                        } label: {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .tint(.white)
                                .padding()
                                .background(.green.gradient)
                                .shadow(radius: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 20), style: .init())
                                .overlay(alignment: .bottom) {
                                    Text("Mode Admin")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.2)
                                        .foregroundStyle(.gray)
                                        .offset(y:20)
                                }
                        }
                        .scaleEffect(utilisateur.this.isAdmin ? 1 : 0)
                        //Deconnexion Square Button
                        
                        Button {
                            //deconnect user
                            appSetting.disconnect()
                        } label: {
                            Image(systemName: "power")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .tint(.white)
                                .padding()
                                .background(.red.gradient)
                                .shadow(radius: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 20), style: .init())
                                .overlay(alignment: .bottom) {
                                    Text("Déconnexion")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.2)
                                        .foregroundStyle(.gray)
                                        .offset(y:20)
                                }
                        }
                        
                    }
                    
                    
                    
                    Text("Je veux supprimer mon compte")
                        .font(.caption)
                        .underline(pattern: Text.LineStyle.Pattern.solid)
                        .foregroundStyle(.gray)
                        .onTapGesture {
                            show_delete_account = true
                        }
                        .confirmationDialog(Text("Confirmation"), isPresented: $show_delete_account) {
                            Button("Oui, Je me désinscris"){
                                //
                                
                                    Task{
                                        let r = await utilisateur.delete(utilisateur.this)
                                        if r{
                                            show_delete_account = false
                                            appSetting.disconnect()
                                        }
                                    }
                                
                            }
                            
                        } message: {
                            Text("Votre compte sera définitivement supprimé de nos serveurs. Voulez vous continuer ?")
                        }


                        
                }
                .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height, alignment: Alignment.center)
                .background(.ultraThinMaterial)
            }
            
            
            //LogOut & deletion button
            HStack{
                Image(systemName: show_options ? "xmark": "rectangle.portrait.and.arrow.forward")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        withAnimation(.spring) {
                            show_options.toggle()
                        }
                    }
            }
            .padding()
            .frame(width: GeometryProxy.size.width, alignment:.trailing)
           
            if show_this_command{
                #warning("To do again this view")
                CommandInDetail(commande: commandToView, client: utilisateur.this, show: $show_this_command)
                    .onAppear{
                        withAnimation {userdata.taskbar = false}
                    }
                    .onDisappear {
                        withAnimation {userdata.taskbar = true}
                    }
            }
        })
        .environmentObject(focusState)
        .background()
        .onAppear{
            if utilisateur.this.isUser{
                utilisateur.review = utilisateur.this
            }else{
                utilisateur.review = userToReview
            }
            
        }
        
        
    }
    
    @State var selectedADS:Int = 3
    @ViewBuilder
    func BackgroundFadeColor(_ proxyScroll:CGSize)->some View{
        GeometryReader { Proxy in
            let minY = Proxy.frame(in: .named("scroll")).minY
            var progress = minY / (proxyScroll.height * 0.6)
            ZStack(alignment:.top){
                
               /// backgroundImageSwitcher()
               AsyncImage(url: URL(string: "http://express.heanlab.com/getimage?name=pub")) { image in
                   image
                       .resizable()
                       .scaledToFill()
                       .scaleEffect(progress > 0 ? progress + 1 : 1)
                       
                   
               } placeholder: {
                   ProgressView()
               }
               
            }
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity)
            .offset(y : -minY) // L'image reste figée
            .overlay(content: {
                let themColor:Color = colorscheme == .dark ? .black : .white
                ZStack (alignment: .center, content: {
                    Rectangle().fill(.linearGradient(colors: [themColor.opacity(0 - progress),
                                                              themColor.opacity(0.1 - progress),
                                                              themColor.opacity(0.2 - progress),
                                                              themColor.opacity(0.5 - progress),
                                                              themColor.opacity(0.7 - progress),
                                                              themColor.opacity(1),]
                                                     , startPoint: .top, endPoint: .bottom))
                    .scaleEffect(progress > 0 ? progress + 1 : 1)
                    .opacity(minY == 0 ? 1 : (1 - progress))
                    .offset(y: -minY)
                    
                    
                })
                .ignoresSafeArea(.all)
                .scaleEffect(progress > 0 ? progress + 1 : 1)
            })
            
            
        }
    }
    
    @ViewBuilder
    func Infos() -> some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 5){
                Text(utilisateur.this.name)
                    .font(.custom("Ubuntu", size: 30))
                Text(utilisateur.this.surname)
                    .font(.headline)
                //Text("#\(userdata.currentUser.id)")
                
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            /*
            Section {
                VStack{
                    //Email entry
                    TextField(text: $utilisateur.this.mail) {
                        Label("Email", systemImage: "house")
                    }
                    //.disabled(!modifyMode)
                    .padding()
                    .background(.ultraThinMaterial)
                    .textContentType(UITextContentType.emailAddress)
                    .clipShape(Capsule())
                    .onChange(of: utilisateur.this.mail) { V in
                        email_is_ok = utilisateur.this.isMailIsCorrect
                    }
                    
                }
                .disabled(edit_mode)
                //.multilineTextAlignment(.center)
                
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
            */
            
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
        GeometryReader{ size in
            ScrollView{
                VStack{
                    Text("Mes commandes")
                        .font(.title)
                        .bold()
                        .padding(.vertical)
                }
                .frame(width:size.size.width,height: 200, alignment: .bottomLeading)
                .background(Color("xpress"))
                //Cards
               
                
            }
            .ignoresSafeArea(.all)
            .edgesIgnoringSafeArea(.top)
                /* 3D CARDS
                 .offset(y:offsetY)
                 .offset(y:currentIndex * -200.0)*/
            //.frame(width: proxy.width, height: proxy.height)
            
            .sheet(isPresented: $commande.edit,onDismiss:{
                let _ = commande.erase()
                commande.editModeOff()
            }, content: {
               // command_view_card(show: $commande.edit)
            })
        }
        //.coordinateSpace(name: "SCROLL")
        .background()
        .background(.linearGradient(colors: [.black.opacity(0.9),.blue.opacity(0.1)], startPoint: .bottom, endPoint: .top))
        .onAppear{
            //fetchModel.fetchUserCommands(user: userdata.currentUser)
            Task{
                userdata.loading = true
                await commande.fetchForuser(utilisateur.this)
                selectedcommand = fetchModel.userCommands.reversed().first ?? Command.init()
                userdata.loading = false
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
            .environmentObject(Commande())
            .environmentObject(Utilisateur())
            .environmentObject(Article())
            .onAppear{
                Task{
                    oldcommand.append(Command(user: 1, status: "sent", cost: Decimal(2.3), dateIn: Date(), message: "2:3,4:6"))
                }
            }
        
    }
}

//Function to switch between images each 5 seconds

func backgroundImageSwitcher() -> AsyncImage<Image> {
    
    var result:Int = Int.random(in: 0...2)
    //Switch every 5 seconds
    while true {
        //wait 5 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 30, execute: .init(block: {
        result = Int.random(in: 0...2)
        }))
    }
    
    return AsyncImage(url: URL(string:"http://express.heanlab.com/getimage?name=\(result)"))
}
