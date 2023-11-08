//
//  CommandInDetail.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 27/10/2023.
//

import SwiftUI

struct CommandInDetail: View {
    @EnvironmentObject var article:Article
    @Environment(\.colorScheme) var colorScheme
    @Binding var commande:Command
    @State var client:User
    @State var cart:Set<Achat>=[]
    var body: some View {
        GeometryReader{
            let size=$0.size
            ScrollView{
                //MARK: Header
                HStack{
                    //Exit Button
                    Button(action: {commande = Command()}, label: {
                        Label("Sortir", systemImage: "xmark.circle.fill")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    })
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(Color("fond"))
                    
                    Spacer()
                    //MARK: When A command is deleted, just close the view after. 
                    Button(action: {Task{let _ = await commande.delete();commande = Command()}}, label: {
                        Label("Supprimer", systemImage: "trash.circle.fill")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    })
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(.red)
                    //.scaleEffect(commande!.isEditable ? 1 : 0)
                }
                .frame(maxWidth: .infinity, alignment:.leading)
                //MARK: Inside the card
                
                VStack(alignment: .leading, spacing:0){
                    //Command header
                    VStack(alignment:.leading){
                        Text("#\(commande.id)")
                            .font(.custom("Ubuntu", size: 10))
                            .foregroundStyle(.gray)
                        //Text(commande!.date_)
                         //   .font(.custom("Ubuntu", size: 10))
                        Text("Client: \(client.name)")
                            .font(.custom("Ubuntu", size: 10))
                        Text("Client-GSM: \(client.phone)")
                            .font(.custom("Ubuntu", size: 10))
                        
                        Divider()
                            .padding()
                        LazyVGrid(columns: [GridItem(.fixed(20)),GridItem(.flexible()),GridItem(.fixed(45)),GridItem(.fixed(45))],alignment:.leading, pinnedViews: [.sectionFooters], content: {
                            Section {
                                Group{
                                    Text("Qté")
                                    Text("Description")
                                    Text("Prix")
                                    Text("Total")
                                }
                                .font(.caption2)
                                .bold()
                                ForEach(cart.sorted(by: {$0.service.id < $1.service.id}), id:\.self) { achat in
                                    Group{
                                        Text("\(achat.quantity)")
                                        Text(achat.service.name)
                                            
                                        Text(achat.service.cost.formatted(.currency(code:"EUR")))
                                        Text((achat.service.cost * Decimal(achat.quantity)).formatted(.currency(code:"EUR")))
                                    }
                                    .font(.caption2)
                                }
                                
                            } footer: {
                                //MARK: Livraison cost, Reduction and total to pay as Recap
                                LazyVGrid(columns: [GridItem(), GridItem(alignment: .trailing)], alignment: .leading) {
                                    Group{
                                        // Subtotal
                                        Text("Sous-total")
                                        Text(commande.sub_total.formatted(.currency(code:"EUR")))
                                        // Delivery
                                        Text("Livraison")
                                        Text(commande.delivery.formatted(.currency(code:"EUR")))
                                        // Discount
                                        Text("Réduction")
                                        Text(commande.discount.formatted(.currency(code:"EUR")))
                                    }
                                    .font(.custom("Ubuntu", size: 20))
                                    
                                    Divider()
                                        .padding()
                                    //MARK: Total to pay
                                    Group {
                                        VStack{
                                            Text("Total à payer")
                                            Text(commande.cost.formatted(.currency(code:"EUR")))
                                        }
                                        
                                    }
                                    .bold()
                                }
                                .padding()
                            }

                        })
                        //MARK: Auxialiaries datas
                        //Address
                        VStack(alignment:.leading,spacing:0){
                            Text("Adresse de contact")
                                .bold()
                            Text(client.adress)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .onTapGesture {
                            let url = NSURL(string: "http://maps.apple.com/?ll=\(client.loc_lat),\(client.loc_lon)")
                            UIApplication.shared.open(url as! URL)
                        }
                        // Recover Infos
                        HStack{
                            Rectangle().fill()
                                .frame(width: 3,height:50)
        
                            VStack(alignment:.leading){
                                Text("Récupération")
                                    .bold()
                                Text(commande.enter_date.toDate().dateUserfriendly())
                                    .font(.caption2)
                                Text("\(commande.enter_time)h - \(Int(commande.enter_time)! + 1)h")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            Rectangle().fill()
                                .frame(height: 1)
                                
                        }
                        // Delivery infos
                        HStack{
                            Rectangle().fill()
                                .frame(height: 1)
                            VStack(alignment:.leading){
                                Text("Récupération")
                                    .bold()
                                Text(commande.return_date.toDate().dateUserfriendly())
                                    .font(.caption2)
                                Text("\(commande.return_time)h - \(Int(commande.return_time)! + 1)h")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            Rectangle().fill()
                                .frame(width: 3,height:50)
                                
                        }
                        //Notes
                        Divider()
                        Text(commande.infos)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .italic()
                    }
                    
                    
                    //
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity, alignment:.topLeading )
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.bar)
                        .shadow(color: .gray, radius: 2)
                }
                .padding(0)
                .overlay(alignment: .topTrailing) {
                    VStack(alignment:.trailing, spacing:0){
                        Text("Ex-Press")
                            .bold()
                        Text("BE0460.715.554")
                            .font(.custom("Ubuntu", size: 10))
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
            }
            .padding()
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.ultraThinMaterial)
            
            .clipShape(RoundedRectangle(cornerRadius: 40.0, style: .circular))
            .padding()
            .padding(.top, 80)
            .task{
                //MARK: Read datas in the command to open
                print(commande.services_quantity)
                //Foreach value in service_quantity, add an Achat in the cart with the quantity
                commande.services_quantity.split(separator: ",").forEach{ achat in
                    let t = String(achat).split(separator:":")
                    let serviceOfID = article.all.first(where: {$0.id == Int(t.first!)})
                    cart.insert(Achat(serviceOfID ?? Service(), Int(t.last!)!))
                    
                }
            }
        }
    }
}

#Preview {
    CommandInDetail(commande: .constant(Command()), client: User(name: "John"), cart: Set(arrayLiteral: Achat(Service(), 4)))
        .environmentObject(Article())
}
