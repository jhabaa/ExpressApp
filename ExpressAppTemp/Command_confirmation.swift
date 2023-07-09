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
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var article:Article
    @Namespace var namespace : Namespace.ID
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            // List of elements
            ScrollView{
                    Section {
                        //Exemple shape
                        /*
                        HStack(alignment:.center){
                            // Image of the service
                           Image("logo120")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 25.5))
                                .frame(width: 100, height: 100)
                                .shadow(radius: 1)
                            
                            //Name of the servive and quantity up and downdable
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Nom du service")
                                    .bold()
                            }
                            Spacer()
                            //Cost
                            ZStack{
                                Text("\((0.23).formatted(.currency(code: "EUR")))").font(.title3).bold()
                                Text("Quantité : ")
                                    .font(.caption2)
                                    .offset(y:20)
                            }
                            .padding(.horizontal)
                                
                        }
                        .background(.bar)
                        .clipShape(RoundedRectangle(cornerRadius: 25.5))
                        .padding(.horizontal)
                        */
                        //Divider()
                        ForEach(commande.services.sorted(by: {$0.service.id < $1.service.id}), id: \.self) { s in
                            // Entry of the cart
                            HStack(alignment:.center){
                                // Image of the service
                                Image(uiImage: (article.images[s.service.illustration] ?? UIImage(named: "logo120"))!)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 25.5))
                                    .frame(width: 100, height: 100)
                                    .shadow(radius: 1)
                                
                                //Name of the servive and quantity up and downdable
                                VStack(alignment: .leading, spacing: 20) {
                                    Text(s.service.name)
                                        .bold()
                                }
                                Spacer()
                                //Cost
                                ZStack{
                                    Text("\((s.price).formatted(.currency(code: "EUR")))").font(.title3).bold()
                                    Text("Quantité : \(s.quantity)")
                                        .font(.caption2)
                                        .offset(y:20)
                                }
                                .padding(.horizontal)
                                
                            }
                            .background(.bar)
                            .clipShape(RoundedRectangle(cornerRadius: 25.5))
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top,300)
                
            }
            
            VStack{
                VStack{
                    Text("Confirmation de commande")
                        .font(.title3).bold()
                    Text("#\(commande.this.id)")
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .foregroundColor(.blue)
                        .scaledToFit()
                        .frame(width: 100)
                        .clipped()
                    Text("Commande Confirmée")
                        .font(.title)
                        .bold()
                }
                .padding()
                .background(Color("xpress").opacity(0.5).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
            }
            .frame(width: size.width, alignment: .center)
            
            
            
            // Continue Button
            VStack{
                
                Button {
                    //Checkout action
                    //userdata.command_confirmation = false
                    //Command.current_cart = [:]
                    Task{
                        userdata.GoToPage(goto: "accueil")
                    }
                } label: {
                    Text("Continuer")
                        .font(.custom("Ubuntu", size: 30))
                        .frame(width: 300)
                }
                //.frame(width: .width, height: size.height, alignment: .bottom)
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .padding()
                .shadow(radius: 2)
            }
            .frame(width:size.width,height: size.height, alignment: .bottom)
            
        }
        .frame(alignment: .center)
        .background(Color("xpress").opacity(0.2).gradient)
        .background(.bar)
    }
}


struct Command_confirmation_Previews: PreviewProvider {
    static var previews: some View {
        Command_confirmation().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Article())
            .environmentObject(Commande())
            .environmentObject(Utilisateur())
    }
}
