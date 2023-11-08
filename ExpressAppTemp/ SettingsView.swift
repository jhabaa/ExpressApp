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
                    .frame(height: 100)
                    .frame(maxWidth:.infinity, maxHeight:100)
                    .background(.bar)
                    
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                }
                .padding()
                    Section {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appSettings.to_user()
                            }
                            //User.disconnect()
                            //userdata.currentUser.LOGGED_USER = 0
                        } label: {
                            
                                Text("Se connecter en tant qu'utilisateur")
                                    .multilineTextAlignment(.center)
                                    .padding()
                        }
                        
                        .buttonStyle(.borderedProminent)
                    } footer: {
                        Text("Quitter ce mode et se connecter en tant qu'utilisateur pour pouvoir passer des commandes ou vérifier l'état des services")
                            .font(.caption2)
                            .padding(.horizontal)
                    }
                    Section {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appSettings.disconnect()
                            }
                            //User.disconnect()
                            //userdata.currentUser.LOGGED_USER = 0
                        } label: {
                                Text("Deconnexion")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.red)
                            
                           
                            
                        }
                        .padding()
                        .background(.bar)
                        .padding(.top,100)
                    } footer: {
                        Text("Fermez votre session")
                            .font(.caption2)
                    }
                    

                
                .onAppear{
                    //fetchModels.fetchSettings()
                }
            }
            .alert("Entrez le nouveau prix", isPresented: $showParams) {
                TextField("", value:
                            selectedParam == .bruxelles ?
                          $parameters.tarif_bruxelles : selectedParam == .brabant ? $parameters.tarif_brabant : $parameters.tarif_km, format: .currency(code: "EUR"))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                
                Button {
                    //
                    showParams = false
                } label: {
                    Text("Annuler")
                }

                Button {
                    // send update
                    Task{
                        let _ = await UpdateParameters(parameters)
                        showParams = false
                        parameters = await RetrieveParameters()!
                    }
                } label: {
                    Text("Valider")
                }

            } message: {
                Text("Merci d'introduire le nouveau prix. Ce prix restera fixe jusqu'au prochain changement")
            }

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
