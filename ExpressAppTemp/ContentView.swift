//
//  ContentView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//

import SwiftUI
import SceneKit

enum notificationStyle{
    case amber, none
}

//3D
struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene
    @State private var isPaused = false
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.clear
        return sceneView
    }
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Mise à jour de la vue si nécessaire
        //uiView.clipsToBounds = true
        //uiView.allowsCameraControl = false
        //uiView.antialiasingMode = SCNAntialiasingMode.none
        //uiView.scene?.lightingEnvironment.intensity = 0.8
        
        // Récupérer l'élément "tube"
        /*
            guard let tube = uiView.scene?.rootNode.childNode(withName: "tube", recursively: true) else {
                return
            }
            
            // Ajouter une animation de rotation en boucle sur l'axe Y
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.fromValue = NSValue(scnVector4: SCNVector4(1, 1, 0, 0))
            rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            rotation.duration = 10 // Durée d'une rotation complète (en secondes)
            rotation.repeatCount = .infinity // Boucler indéfiniment

        if uiView.window != nil {
                tube.addAnimation(rotation, forKey: "rotation")
            } else {
                tube.animationPlayer(forKey: "rotation")?.stop()
            }
       */
    }
}

var user:String = ""
struct ContentView: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var fetchmodel:FetchModels
    @EnvironmentObject var appSettings:AppSettings
    @EnvironmentObject var panier:Panier
    @EnvironmentObject var article:Article
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var alerte:Alerte
    @EnvironmentObject var days:Days
    @State var firstViewShowed:Bool = false
    @State private var showSheet1 = false
    @State var home:Bool = true
    @State var person:Bool = false
    @State var cart:Bool = false
    @State var showMenu:Bool = true
    @State var loading_error:Bool = true
    @State var notificationPadding:CGFloat = -250.0
   //@State var connection_error:Bool = true
    var body: some View {
        GeometryReader { GeometryProxy in
            VStack(spacing:0){
                //MARK: Notification Header
                HStack(alignment:.bottom){
                    Image(uiImage: (alerte.icon ?? UIImage(named: "logo180"))!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .foregroundStyle(.white, .gray)
                        
                    VStack(alignment:.leading){
                        Text(alerte.value)
                            .font(.custom("Ubuntu", size: 20))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding()
                .frame(height: notificationPadding, alignment:.bottom)
                .background(Color("xpress"))
                .onChange(of: alerte.type) { V in
                    switch alerte.type {
                    case .amber:
                        notificationPadding = 150
                        Task{
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: DispatchWorkItem.init(block: {
                                //Close notification
                                alerte.EraseNotification()
                            }))
                        }
                    case .none:
                        notificationPadding = 0
                    }
                }
                //.padding(.top, notificationPadding)
                .animation(.spring(blendDuration: 2), value: notificationPadding)
               // .transformEffect(.init(translationX: 0, y: -200))
                if appSettings.logged{
                    if appSettings.loggedAs == .administrator{
                        AdminView().transition(.identity)
                            .animation(.spring(blendDuration: 2), value: notificationPadding)
                    }
                    
                    if appSettings.loggedAs == .user{
                        UserView().transition(.identity)
                            
                        .overlay(alignment: .bottom) {
                            TaskView()
                        }
                        .animation(.spring(blendDuration: 2), value: notificationPadding)
                    }
                }else{
                    VStack{
                        FirstScreen(showMenu: $showMenu, showHome: $home)
                            .zIndex(3)
                            .animation(.spring(), value: appSettings.logged)
                            .animation(.spring(blendDuration: 2), value: notificationPadding)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight:.infinity)
            .edgesIgnoringSafeArea(.all)
            
            //server connection overlay
            ZStack{
                LoadingView()
                    .opacity(appSettings.loading ? 1 : 0)
                    .offset(y:appSettings.loading ?  0 : GeometryProxy.size.height)
                    .animation(.easeInOut, value: appSettings.loading)
                Text("Connexion aux serveurs...")
                    .offset(y:100)
                    .scaleEffect(y:appSettings.loading ? 1 : 0, anchor: .leading)
                    .animation(.spring, value: appSettings.loading)
                
            }
            .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height, alignment: .center)
        }
        .textInputAutocapitalization(.never)
        //debug
        .onChange(of: appSettings.logged, perform: { newValue in
            print(newValue)
        })
        .confirmationDialog("Erreur de connexion", isPresented: $appSettings.connection_error) {
            Button("Réessayer", role: ButtonRole.destructive) {
                Task{
                    let handle = Task{
                        return await article.fetch()
                    }
                    appSettings.connection_error = await !handle.value
                }
            }
        }message:{
            Text("Impossible de se connecter au serveur. Veuillez vérifier votre connection internet et vous assurer que vos identifiants sont corrects. Cliquez sur Annuler pour entrer de nouveaux identifiants.")
        }
        
        .task{
            let handle = Task{
                return await article.fetch()
            }
            appSettings.connection_error = await !handle.value
            Task{
                //alerte.setAlert(await handle.value)
                loading_error = appSettings.connection_error
            }
        }
        //loading
        .overlay {
            if userdata.loading {
                LoadingView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(AppSettings())
            .environmentObject(Panier())
            .environmentObject(Article())
            .environmentObject(Utilisateur())
            .environmentObject(Alerte())
            .environmentObject(Days())
    }
}
