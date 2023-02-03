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
                        .background{
                            RoundedRectangle(cornerRadius: 10 ).fill(Color("fond").opacity(0.9))
                                .matchedGeometryEffect(id: "start", in: namespace)
                                .shadow(radius: 2)
                        }
                        .padding(.vertical, 30)
                        .onTapGesture {
                            // Show Sign In view
                            withAnimation(.easeInOut){
                                connectionPresentation.toggle()
                            }
                        }
                    }
                    // Se connecter avec
                    /*
                    HStack {
                        Rectangle()
                          .frame(width: 100, height: 1)
                          .foregroundColor(.gray)
                          .background(Color.clear)
                        Text("Se connecter avec").bold().font(.caption)
                            
                        Rectangle()
                          .frame(width: 100, height: 1)
                          .foregroundColor(.gray)
                          .background(Color.clear)
                    }
                    HStack {
                        Image(systemName: "apple.logo")
                            .scaleEffect(1.5)
                            .colorInvert()
                            .padding()
                            .onTapGesture {
                                
                            }
                            .background{
                                Circle().fill()
                            }
                            
                    }.padding()*/
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
                .padding(.vertical, 30)
                .coordinateSpace(name: "btn1")
                .matchedGeometryEffect(id: "btn1", in: namespace)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .fullScreenCover(isPresented: $signInView, onDismiss: {
            }, content: {
                //#warning("Fix this before commit")
                SignIN(_show: $signInView)
                  //  .background(.clear)
            })
            
            
            if connectionPresentation{
                ConnectionView(connectionView: $connectionPresentation, showMenu: $showMenu)
                    //.background(.ultraThinMaterial)
                    .matchedGeometryEffect(id: "start", in: namespace)
                    .padding(.top, 200)
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
    }
}
