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
        let rndNumber:Int = Int.random(in: 0...1)
        let choice:[String]=["vid1","vid2"]
        // Load the resource -> h
        let fileUrl = Bundle.main.url(forResource: choice[rndNumber], withExtension: "mp4")!
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
    enum connectionField{
        case username, password
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
    @EnvironmentObject var alerte:Alerte
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focusedArea: connectionField?
    @StateObject private var focusState = focusObjects()
    @FocusState var focustate:adress_field?
    @FocusState var focusField:user_field?
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
    @State var forgotPassword:Bool = false
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
                        VStack{
                            HStack(spacing:0){
                                Image(systemName: "person.crop.square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                CustomTextField(_text: $utilisateur.this.name, _element: "utilisateur",hideMode:false, type:.text, name:"Nom d'utilisateur")
                                    .focused($focusedArea, equals: .username)
                                    .submitLabel(.next)
                            }
                            .focused($focusedArea, equals: .username)
                            //.clipShape(RoundedRectangle(cornerRadius: 10))
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(.blue.opacity(focusedArea == .username ? 1 : 0), lineWidth: 2)
                            }
                            //Password Field
                            HStack(spacing:0){
                                Image(systemName: "key.viewfinder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                CustomTextField(_text: $utilisateur.this.password, _element: "mot de passe"
                                    ,hideMode:false,
                                    type:.password)
                                .focused($focusedArea, equals: .password)
                                .submitLabel(.continue)
                            }
                            .focused($focusedArea, equals: .password)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(.blue.opacity(focusedArea == .password ? 1 : 0), lineWidth: 2)
                                   
                            }
                            
                            //Bouton
                            Button {
                                appSettings.loading = true
                                Task {
                                    //MARK: Update the current user if datas are correct
                                    utilisateur.this = await utilisateur.connect(user: utilisateur.this) ?? User()
                                    //MARK: Error handler and loading
                                    appSettings.connection_error = utilisateur.this.isEmpty
                                    //MARK: If everything is okay lets change the view and keep out the loading page
                                    if !appSettings.connection_error{
                                        appSettings.connect(utilisateur.this.type) // Connect the user to the interface
                                        alerte.NewNotification(.amber, "Bonjour \(utilisateur.this.name)", UIImage(systemName: "person.crop.circle.fill.badge.checkmark"))
                                    }
                                    appSettings.loading = false //Turn off the loading view
                                    
                                }
                                
                            } label: {
                                let emptyNameAndPassword = (utilisateur.this.name.isEmpty || utilisateur.this.password.isEmpty)
                                    Text("Se Connecter").font(.system(size: 20))
                                        .padding()
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                        .background{
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .opacity(emptyNameAndPassword ? 0 : 1)
                                                .animation(.spring, value: emptyNameAndPassword)
                                                
                                        }
                                        .opacity(emptyNameAndPassword ? 0 : 1)
                                        .offset(y:emptyNameAndPassword ? 100 : 0)
                                        .animation(.spring, value: emptyNameAndPassword)
                            }
                            .padding()
                            .buttonStyle(.borderless)
                            .buttonBorderShape(.roundedRectangle(radius: 10))
                            .tint(colorScheme == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 30)
                        
                        //MARK: Forgot password
                        Button(action: {
                            connectionPresentation.toggle()
                            forgotPassword.toggle() // Toggle the forgot password alert
                        }, label: {
                            Text("Mot de passe oublié")
                                .font(.caption)
                                .underline()
                                .foregroundStyle(.gray)
                        })
                       
                        #warning("Have to implement this in the backend before activate")
                    }
                    .padding()
                    //.background(.ultraThinMaterial)
                    //.clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    .shadow(radius: 2)
                    .padding(20)
                    .frame(maxWidth: 390)
                   
                   
                }
                .preferredColorScheme(.dark)
                .frame(maxWidth: .infinity, maxHeight:.infinity, alignment:.bottom)
                .onSubmit {
                    switch focusedArea {
                    case .username:
                        focusedArea = .password
                    case .password:
                        appSettings.loading = true
                        Task {
                            utilisateur.this = await utilisateur.connect(user: utilisateur.this) ?? User()
                            appSettings.connection_error = utilisateur.this.isEmpty
                            if !appSettings.connection_error{
                                appSettings.connect(utilisateur.this.type) // Connect the user to the interface
                                appSettings.loading = false //Turn off the loading view
                            }
                        }
                    case nil:
                        focusedArea = nil
                    }
                }
            }
            if signInView{
                SignIN(_show: $signInView, place: IdentifiablePlace.init(lat: 50.8, long: 4))
                    .background(.ultraThinMaterial)
            }
        }
        .onTapGesture {
            withAnimation(.spring()){
                connectionPresentation = false
            }
        }
        .frame(alignment: .bottom)
        
        .background{
            let colorWhenPresentationIsOff = connectionPresentation ? 0.4 : 0
                VStack{
                    if !signInView && !connectionPresentation{
                        PlayerView()
                            .blur(radius: connectionPresentation ? 12.4 : 0, opaque: true)
                            .overlay(alignment: .top) {
                               // LinearGradient(colors: [Color("fond").opacity(1),Color("fond").opacity(colorWhenPresentationIsOff)], startPoint: .top, endPoint: .center)
                                    
                                    
                                LinearGradient(colors: [Color("fond").opacity(1),Color("fond").opacity(colorWhenPresentationIsOff)], startPoint: .bottom, endPoint: .center)
                                    
                            }
                            .ignoresSafeArea()
                    }else{
                        
                            RadialGradient(colors: [Color("xpress"), colorScheme == .dark ? .black : .white], center: .topLeading, startRadius: 100, endRadius: 700)
                                .blur(radius: 100)
                        
                    }
                    
                }
                .frame(maxWidth:.infinity, maxHeight:.infinity)
                .overlay(alignment: signInView ? .topTrailing : .top) {
                        ExpressLogo()
                            .matchedGeometryEffect(id: "logo", in: namespace)
                            .offset(y:50)
                            .scaleEffect((connectionPresentation || signInView) ? 0.5 : 1)
                            .opacity(signInView ? 0.4 : 1)
                            .animation(.spring(response: 0.2, dampingFraction: 0.3), value: connectionPresentation)
                    }
                    .onTapGesture{
                        connectionPresentation = false
                    }
        }
        .environmentObject(focusState)
        .alert("Mot de passe oublié", isPresented: $forgotPassword) {
            var value:Bool = false
            if !value{
                TextField("nom d'utilisateur ou email", text: $utilisateur.this.mail)
                    .foregroundStyle(.blue)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }else{
                Text("Consultez vos mails pour terminer le processus de réinitialisation")
            }
           
            
            Button(!value ? "Annuler" : "Terminer") {
                forgotPassword = false
            }
            if !value{
                Button("Réinitialiser") {
                    //MARK: Action to réinitialize a password
                    Task{
                        value = utilisateur.ResetPassword(utilisateur.this)
                    }
                }
            }
                } message: {
                    Text("Veuillez entrer votre adresse mail ou nom d'utilisateur pour réinitialiser votre compte")
        }
        
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
            .environmentObject(Alerte())
    }
}
