//
//  ManageCommand.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 09/05/2022.
//

/**
 Classe de vue détaillée d'une commande sur un compte administrateur. L'administrateur peut à partir de cette vue attribuer un agent à une commande.
 
 */

import SwiftUI

struct ManageCommand: View {
    @State var command:Command
    @StateObject var fetchModel = FetchModels()
    @Binding var showDetailCommand:Bool
    var clipboard = UIPasteboard.general
    var body: some View {
        GeometryReader { GeometryProxy in
            ScrollView{
                VStack(alignment:.leading){
                    //Header
                    Text("Gestionnaire de Commande").font(.title).bold()
                    //Text("\(command.id)").font(.caption).foregroundColor(.secondary)
                    
                    //Attribution de mission
                    
                    Menu {
                        ForEach(fetchModel.GetEmployees(), id : \.id ) { index in
                            Button("\(index.name)"){ }
                        }
                    } label: {
                        Text("Agent : \(fetchModel.getUserName(id: command.agent).name)")
                    }
                    
                    //Informations Client
                        VStack(alignment:.center){
                            Image(systemName: "person.circle.fill").resizable().frame(width: 100, height: 100)
                            HStack{
                                //Text("\(fetchModel.GetUserInCommand(id: command.id).SURNAME_USER)").font(.caption2).foregroundColor(.secondary)
                                //Text("\(fetchModel.GetUserInCommand(id: command.id).NAME_USER)").font(.caption)
                            }.padding(.bottom)
                            
                            //Appel et message
                            HStack{
                                Button {
                                   // guard let url = URL(string: "tel://\(fetchModel.GetUserInCommand(id: command.id).PHONE_USER)") else {return}
                                    //UIApplication.shared.open(url)
                                } label: {
                                    VStack{
                                        Image(systemName: "phone.circle.fill").resizable().frame(width: 50, height: 50)
                                        Text("Appeler Client")
                                    }
                                }
                                .tint(.green)
                                .padding(.horizontal)
                                //Message
                                
                                Button {
                                    
                                } label: {
                                    VStack{
                                        Image(systemName: "message.fill").resizable().frame(width: 50, height: 50)
                                        Text("Envoyer Message")
                                    }
                                    
                                }
                                .tint(.blue)
                            }
                            .padding(.bottom)
                            
                            //Adresse
                            Text("Taper sur la carte pour copier l'adresse").padding(0).font(.caption).foregroundColor(.secondary)
                            ZStack{
                                Image(systemName: "location.fill").resizable().scaledToFit().opacity(0.2)
                                VStack {
                                    Text("Adresse du Client").frame(maxWidth: .infinity,  alignment: Alignment.center)
                                    //Text("\(fetchModel.GetUserInCommand(id: command.id).ADDRESS_USER)").font(.title).bold()
                                   // Text("\(fetchModel.GetUserInCommand(id: command.id).CITY_USER)").font(.title).bold()
                                }.scaledToFit()
                            }
                                .frame(height: 100, alignment: Alignment.leading)
                                .background(RadialGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.7)], center: UnitPoint.bottomTrailing, startRadius: 20, endRadius: 100))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .foregroundColor(.white)
                                .padding()
                                .onTapGesture {
                                    //clipboard.string = "\(fetchModel.GetUserInCommand(id: command.id).ADDRESS_USER)"
                                }
                            
                            //Récapitulatif de commande
                            VStack {
                                Capsule().frame(width: 40, height: 10).frame(maxWidth: .infinity, alignment: Alignment.center)
                                Text(230.formatted(.currency(code: "EUR"))).bold()
                                Spacer()
                            }.background(.ultraThickMaterial).frame(height: GeometryProxy.size.height)
                        }.frame(width: GeometryProxy.size.width, alignment: Alignment.center)
                }
            }
            .onAppear {
                //fetchModel.FetchUserHasCommmands()
                fetchModel.fetchCommands()
                fetchModel.fetchUsers()
            }
            .overlay(alignment: Alignment.topTrailing) {
                Button {
                    withAnimation(.spring()) {
                        //currentPage.toggle()
                        //homPage.toggle()
                        showDetailCommand = false
                    }
                } label: {
                    Image(systemName: "arrow.backward.circle.fill").resizable().frame(width: 40, height: 40, alignment: Alignment.center)
                }.padding(40)
            }
        }
        
    }
}

