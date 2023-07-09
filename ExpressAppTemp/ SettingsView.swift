//
//   SettingsView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 04/04/2023.
//
import Foundation
import SwiftUI

enum param {
    case bruxelles
    case brabant
    case km
    
    func nameOf() -> String{
        //
        return self == .brabant ? "Brabant" : self == .bruxelles ? "Bruxelles" : "au Km"
    }
    
}

struct _SettingsView: View {
    //@StateObject var fetchModels = FetchModels()
    @EnvironmentObject var userdata : UserData
    @EnvironmentObject var appSettings:AppSettings
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var daysoffView:Bool = false
    //Params
    @State var parameters:Params=Params()
    @State var showParams:Bool = false
    @State var selectedParam:param = .km
    var body: some View {
        GeometryReader { GeometryProxy in
            ScrollView{
                LazyVGrid(columns: columns) {
                    Group{
                        VStack{
                            
                            Label("Annonce Publique", systemImage: "square.and.arrow.up.circle")
                        }
                        
                        VStack{
                            Label("Tarif Bruxelles", systemImage: "car.rear.road.lane")
                        }
                        .onTapGesture {
                            showParams = true
                            selectedParam = .bruxelles
                        }
                        
                        VStack{
                            Label("Tarif Brabant", systemImage: "car.rear.road.lane")
                        }
                        .onTapGesture {
                            showParams = true
                            selectedParam = .brabant
                        }
                        VStack{
                            Label("Tarif au Kilomètre", systemImage: "car.rear.road.lane")
                        }
                        .onTapGesture {
                            showParams = true
                            selectedParam = .km
                        }
                        
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth:.infinity)
                    .background(Color("xpress").opacity(0.3).gradient)
                    .background(.bar)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                }
                .padding()
                    Section {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appSettings.to_admin()
                            }
                            //User.disconnect()
                            //userdata.currentUser.LOGGED_USER = 0
                        } label: {
                            VStack(alignment:.center){
                                Text("Se connecter en tant qu'utilisateur")
                                    .multilineTextAlignment(.center)
                                    //.foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            
                        }
                        .buttonStyle(.borderedProminent)
                    } footer: {
                        Text("Quitter ce mode et se connecter en tant qu'utilisateur pour pouvoir passer des commandes ou vérifier l'état des services")
                            .font(.caption2)
                    }
                    Section {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appSettings.disconnect()
                            }
                            //User.disconnect()
                            //userdata.currentUser.LOGGED_USER = 0
                        } label: {
                            VStack(alignment:.center){
                                Text("Deconnexion")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity)
                            
                        }
                        .padding()
                        .background(.bar)
                        .padding(.top,100)
                    } footer: {
                        Text("Fermer votre session")
                            .font(.caption2)
                    }
                    

                
                .onAppear{
                    //fetchModels.fetchSettings()
                }
            }
            
            VStack{
                VStack{
                    Text("Entrez le nouveau prix \(selectedParam.nameOf())")
                        .frame(maxWidth: .infinity)
                    TextField("", value:
                                selectedParam == .bruxelles ?
                              $parameters.tarif_bruxelles : selectedParam == .brabant ? $parameters.tarif_brabant : $parameters.tarif_km, format: .currency(code: "EUR"))
                        .padding()
                        .background(.bar)
                        .multilineTextAlignment(.center)
                    
                    Button("Valider"){
                        // send update
                        Task{
                            await UpdateParameters(parameters)
                            showParams = false
                            parameters = try await RetrieveParameters()!
                        }
                        
                    }
                    .padding()
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
                    
                }
                .padding()
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .background()
                .padding()
                
                // Close Btn
                Button {
                    //Close action
                    showParams = false
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .tint(.red)
                        .padding()
                        .scaledToFit()
                        .frame(width: 80)
                        
                }

            }
            .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height, alignment: .center)
            .background(.bar)
            .scaleEffect(showParams ? 1 : 0)
        }
        .frame(alignment: .center)
        .onAppear(perform: {
            Task{
               parameters = await RetrieveParameters() ?? Params()
            }
            
        })
    }

}


struct Previews__SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        _SettingsView()
            .environmentObject(UserData())
    }
}
