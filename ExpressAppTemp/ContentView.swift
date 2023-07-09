//
//  ContentView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//

import SwiftUI
import SceneKit

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
    @State var firstViewShowed:Bool = false
    @State private var showSheet1 = false
    @State var home:Bool = true
    @State var person:Bool = false
    @State var cart:Bool = false
    @State var showMenu:Bool = true
    var body: some View {
        GeometryReader { GeometryProxy in
            //first screen with animate logo in the background
            //We show FirstScreen connection view if:
                // -- loggedUser == 0 = user disconnected
                // -- not images for all services
                // -- And the most important, the current ID_user == 0 . 0 is reserved here for empty
            //Background
            if (appSettings.show_logo){
                SceneKitView(scene: SCNScene(named: "SceneKitScene.scn")!)
                            .edgesIgnoringSafeArea(.all)
            }
            
            if appSettings.logged{
                if utilisateur.this.isAdmin{
                    AdminView().transition(.identity)
                }
                
                if utilisateur.this.isUser{
                    UserView().transition(.identity)
                    .overlay(alignment: .bottom) {
                        TaskView()
                    }
                }
            }
            
            if (!appSettings.logged){
                VStack{
                    FirstScreen(showMenu: $showMenu, showHome: $home)
                        .zIndex(3)
                        .animation(.spring(), value: appSettings.logged)
                }
            }
            //loading if images set is not full
            /*
            if (!fetchmodel.services_ready){
                VStack(alignment: .center, spacing: 20) {
                    Text("Chargement")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background()
                
            }
            */
            //if network issue
            if !appSettings.networkIsOn{
                VStack{
                    Text("Réseau indisponible")
                        .foregroundStyle(.red)
                        .bold()
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                }.frame(width: GeometryProxy.size.width, alignment: .center)
            }
            
            //Notification
            Notification()
        }
        .textInputAutocapitalization(.never)
        .background{
            LinearGradient(colors: [Color("xpress").opacity(0.7), Color("xpress").opacity(0.0)], startPoint: UnitPoint.bottomTrailing, endPoint: .topLeading)
                .ignoresSafeArea()
        }
        //debug
        .onChange(of: appSettings.logged, perform: { newValue in
            print(newValue)
        })
        .onAppear{
            Task{
                var n = await article.fetch()
            }
        }
        
        //Notification
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
    }
}
