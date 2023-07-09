//
//  FirstScreen.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 26/03/2022.
//

import SwiftUI

//Adress enum tto use focus to show each in the screen when keyboard is up


// ARC circle Struct
struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)

        return path
    }
}


//video background
import AVKit
import AVFoundation


struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: .infinite)
    }
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Load the resource -> h
        let fileUrl = Bundle.main.url(forResource: "vid1", withExtension: "mp4")!
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        // Setup the player
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        playerLayer.speed = player.rate
        
        // Start the movie
        player.play()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
//extension pour l'effet de transparence
extension View{
    func blurSheet<Content: View>(_ style: AnyShapeStyle, show: Binding<Bool>, onDismiss: @escaping ()->(), @ViewBuilder content: @escaping ()-> Content) -> some View{
        self
            .sheet(isPresented: show, onDismiss: onDismiss){
                content()
                    .background(RemoveBackgroundColorSheet())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background{
                        Rectangle()
                            .fill(style)
                            .ignoresSafeArea(.container, edges: .all)
                    }
            }
    }
}
fileprivate struct RemoveBackgroundColorSheet:UIViewRepresentable{
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}

struct FirstScreen: View {
    enum user_field{
        case username
        case password
        case v_password
    }
    enum adress_field:Hashable{
        case road
        case no
        case supl
        case cp
        case city
    }

    @EnvironmentObject var fetchModels:FetchModels
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var appSettings:AppSettings
    @EnvironmentObject var utilisateur:Utilisateur
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var focusState = focusObjects()
    @FocusState var focustate:adress_field?
    @FocusState var focusField:user_field?
    //@AppStorage("id") private var id = ""
    @State var signInView:Bool = false
    @State var notification:Bool = false
    @State var connectionView:Bool = false
    @State var animationStart:Bool=false
    @State var showLoading:Bool = false
    @State var showAddUserView:Bool = false
    @State var showLogIn:Bool = false
    @Binding var showMenu:Bool
    @Binding var showHome:Bool
    @State var imageAnimation: Bool = false
    @State var StackPosition:Double = 0.0
    @State var passed:Bool = false
    @FocusState private var keyboardIsUP:Bool
    @State var currentPage = 0
    @State var NewUser = User.init()
    @State var username:String=String.init()
    @State var password = String.init()
    @State var v_password = String.init()
    @State var connectionPresentation:Bool = false
    @State var passwordIsValid:Bool = false
    @State var formIsOk:Bool = false
    @Namespace var namespace
    //Adress form
    @State var _road:String=String()
    @State var _number:String=String()
    @State var _sup:String=String()
    @State var _postal_code:String=String()
    @State var _city:String=String()
    @State var _adress:[String]=["","","","",""]
    @State private var keyboardHeight:CGFloat = 0
    @FocusState private var road_isfocused:Bool
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            VStack{
                VStack{
                    //Boutons SignIn et continuer sans enregistrement
                        //SignIn
                    if !connectionPresentation{
                        Text("Commencer")
                        .font(.title)
                        .padding()
                        .padding(.horizontal, 30)
                        .foregroundStyle(colorScheme == .dark ? .black.opacity(0.8):.white.opacity(0.8))
                        .background{
                            Capsule()
                                .fill()
                                .shadow(color: Color("xpress").opacity(0.8), radius: 10)
                                
                        }
                        .padding(.vertical, 30)
                        .onTapGesture {
                            // Show Sign In view
                            withAnimation(.spring){
                                connectionPresentation.toggle()
                            }
                        }
                    }
                    
                    if !connectionPresentation{
                        if #available(iOS 16.0, *) {
                            HStack(spacing:20){
                                Text("Pas de compte?")
                                    
                                Button {
                                    signInView.toggle()
                                } label: {
                                    Text("S'enregister")
                                }
                                
                            }.bold().padding()
                        } else {
                            // Fallback on earlier versions
                            HStack(spacing:20){
                                Text("Pas de compte?")
                                    .foregroundColor(.blue)
                                    //.colorInvert()
                                Button {
                                    
                                } label: {
                                    Text("S'enregister").bold()
                                }
                                
                            }
                        }
                    }
                    
                }
                .padding(.vertical, 30)
                .coordinateSpace(name: "btn1")
                .matchedGeometryEffect(id: "btn1", in: namespace)
            }
            .frame(width: size.width, height: size.height, alignment: .bottom)
            
            //Connexion stack
            if connectionPresentation{
                VStack{
                    VStack{
                        CustomTextField(_text: $utilisateur.this.name, _element: "utilisateur",hideMode:false, type:.text, name:"Nom d'utilisateur")
                                //.shadow(color: .secondary, radius: 5)
                        
                        
                        //Password
                            CustomTextField(_text: $utilisateur.this.password, _element: "mot de passe"
                                ,hideMode:false,
                                type:.password)
                            //.shadow(color: .secondary, radius: 5)

                        //Bouton
                        

                        Button {
                            Task {
                                let response = await utilisateur.connect(user: utilisateur.this)
                                if response{
                                    print("connexion")
                                    appSettings.connect()
                                }
                            }
                        } label: {
                            VStack{
                                Text("Se Connecter").font(.system(size: 20))
                                    .padding()
                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                            }
                            .frame(maxWidth: .infinity)
                                
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 10))
                        .tint(colorScheme == .dark ? .white : .black)
                        
                        
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    //.frame(width: size.width, height: 300, alignment:.center)

                    .ignoresSafeArea(.keyboard)
                }
                .ignoresSafeArea(.keyboard, edges: Edge.Set.bottom)
            }
           
            
            if signInView{
                SignIN(_show: $signInView, place: IdentifiablePlace.init(lat: 50.8, long: 4))
            }
        }
        .onAppear{
            /*
            Task{
                if !userdata.currentUser.NAME_USER.isEmpty{
                    //save userdata
                    await UserData.save(user:userdata.currentUser){
                        result in
                        switch result{
                        case .success(_):
                            print("Enregistrement")
                        
                        case .failure(_):
                            print("")
                        
                        }
                    }
                }
                
            }*/
        }
        .onTapGesture {
            withAnimation(.spring()){
                connectionPresentation = false
            }
        }
        .frame(alignment: .bottom)
        
        .background{
            let colorWhenPresentationIsOff = connectionPresentation ? 0.4 : 0
            if !signInView{
                PlayerView()
                    .blur(radius: connectionPresentation ? 12.4 : 0, opaque: true)
                    
                    .overlay(alignment: .top) {
                        LinearGradient(colors: [Color("fond").opacity(1),Color("fond").opacity(colorWhenPresentationIsOff)], startPoint: .top, endPoint: .center)
                            
                            
                        LinearGradient(colors: [Color("fond").opacity(1),Color("fond").opacity(colorWhenPresentationIsOff)], startPoint: .bottom, endPoint: .center)
                            
                    }
                    .overlay(alignment: .top) {
                        ExpressLogo()
                            .matchedGeometryEffect(id: "logo", in: namespace)
                    }
                    .onTapGesture{
                        connectionPresentation = false
                    }
            }
           
                
        }
        .environmentObject(focusState)
        
    }
    ///This function get adress parts in and return true if adress seems correct
    
    @State private var activePage:PageRegistration = pagesRegistration[0]
    @State var numberGSM:String = String()
    
    func SlidePageToLeft(){
        currentPage += 1
        StackPosition += UIScreen.main.bounds.width
    }
  
}


func LoginAction(loginText:inout String, loginBlocState:inout Bool){
    
    loginText = "Valider"
    print("Bouton valider activé")
    loginBlocState = true
    
}

func Password_verification(a:String, b:String)->Bool{
    print("mot1 : \(a) mot2 : \(b)")
    if (a == b){
        if (a.isEmpty){
            return false
        }else{
            return true
        }
    }else{
        return false
    }
}



struct FirstScreen_Previews: PreviewProvider {
    static var previews: some View {
        FirstScreen(showMenu: .constant(true), showHome: .constant(false))
            .environmentObject(FetchModels())
            .environmentObject(UserData())
            .environmentObject(Utilisateur())
    }
}
