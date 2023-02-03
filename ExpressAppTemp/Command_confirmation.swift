//
//  Command_confirmation.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/04/2023.
//

import SwiftUI

struct Command_confirmation: View {
    @EnvironmentObject var fetchmodel : FetchModels
    @EnvironmentObject var userdata:UserData
    @Namespace var namespace : Namespace.ID
    @Binding var _command_id:Int
    var body: some View {
        GeometryReader { _ in
            VStack{
                Text("Confirmation de commande")
                    .font(.title3).bold()
                Text("#\(_command_id)")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                Spacer()
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .foregroundColor(.green)
                    .scaledToFit()
                    .frame(width: 100)
                    .clipped()
                Text("Commande Confirmée")
                    .font(.title)
                    .bold()
                List {
                    Section {
                        ForEach(Command.current_cart.keys.sorted(by: {$0.time < $1.time}), id: \.self) {
                            service in
                            withAnimation(.spring()){
                                HStack{
                                    AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(service.name)") , content: { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .frame(width: 70, height: 70)
                                    }, placeholder: {
                                        ProgressView()
                                            .scaledToFill()
                                            .clipped()
                                            .frame(width: 100)
                                            .cornerRadius(20)
                                            .padding()
                                    })
                                    .matchedGeometryEffect(id: "\(service.name)", in: namespace)
                                    VStack(alignment: .leading, spacing: 10){
                                        //Infos d'article
                                        Text("\(service.name)")
                                            .font(.title2).bold()
                                        Text("\(service.categories)")
                                            .font(.callout)
                                        //prix unitaire
                                        Text("\((service.cost).formatted(.currency(code: "EUR")))").font(.title3).bold()
                                    }
                                }
                                .shadow(radius: 10)
                                .badge(
                                    "QTE:\(Command.current_cart[service] ?? 0)"
                                )
                            }
                        }
                    } header: {
                        //Thanks
                        Text("Merci de faire appel à nos services. Nous avons envoyé une confirmation à votre adresse mail : \(userdata.currentUser.mail)")
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        //Estimation récup
                        var recupDate = Date()
                        HStack{
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.accentColor)
                            Text("Récupération estimée :\(recupDate.dateUserfriendly())")
                                .foregroundColor(.accentColor).bold()
                        }
                        .onAppear{
                            Task{
                                recupDate = userdata.currentCommand.enter_date.toDate()
                            }
                        }
                        .padding()
                        Spacer()
                        Text("Articles")
                            .font(.title2).bold()
                            .multilineTextAlignment(.leading)
                    }
                footer:{
                    Divider()
                        .padding(.bottom, 150)
                }
                }
                .listStyle(.grouped)
                .background(.ultraThinMaterial)
            }.frame(alignment: .center)
                .presentationDetents([.large])
                .overlay(alignment:.bottom){
                    Button {
                        //Checkout action
                        userdata.command_confirmation = false
                        Command.current_cart = [:]
                        Task{
                            userdata.GoToPage(goto: "accueil")
                        }
                    } label: {
                        Text("Continuer")
                            .font(.custom("Ubuntu", size: 30))
                            .frame(width: 300)
                    }
                    //.frame(width: .width, height: size.height, alignment: .bottom)
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
        }
    }
}


struct Command_confirmation_Previews: PreviewProvider {
    static var previews: some View {
        Command_confirmation(_command_id:Binding(projectedValue: .constant(124574))).environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}
