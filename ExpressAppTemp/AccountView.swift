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

enum optionBtn{
    case home, options, hidden
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
    @State var show_options:optionBtn = .home
    @State var show_delete_account = false
    @State var place: IdentifiablePlace = .init(lat: 50.87353, long: 4.48712)
    @State var show_this_command:Bool = false
    @State var commandToView:Command=Command()
    var body: some View {
        GeometryReader(content: { _ in
            UserDetailView(user: utilisateur.this)

            if !commandToView.isNil{
                CommandInDetail(commande: $commandToView, client: utilisateur.this)
                    .onAppear{
                        withAnimation {
                            
                            userdata.taskbar = false
                        }
                    }
                    .onDisappear{
                        show_options = .home
                    }

            }
            
            
        })
        //.ignoresSafeArea(.container)
        .environmentObject(focusState)
        .background{
            RadialGradient(colors: [Color("xpress"), colorscheme == .dark ? .black : .white], center: .topLeading, startRadius: 100, endRadius: 700)
                .blur(radius: 100)
        }
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

