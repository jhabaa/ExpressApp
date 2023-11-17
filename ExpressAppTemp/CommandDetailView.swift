//
//  CommandDetailView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 08/04/2022.
//

import SwiftUI
import MapKit

struct ExpressGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        GroupBox(configuration)
            .cornerRadius(30)
            .shadow(radius: 2)
            .background(.ultraThinMaterial)
    }
}

struct CommandDetailView: View {
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var article:Article
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var alerte:Alerte
    @Environment(\.colorScheme) var colorScheme
    @State var commande:Command
    @State var panier:Set<Achat>=[] // Where Achat == quantity/service
    @State var price:Decimal=Decimal()
    @State var user:User=User()
    @State var newPurchase:Achat = Achat(quantity: 0)
    @State var availablesArticle:[Service]=[]
    @Binding var show:Bool
    @State var newDateIn = Date()
    @State var newDateOut = Date()
    @State var possibleTimesIn:[Int]=[]
    @State var possibleTimesOut:[Int]=[]
    var body: some View {
        
                //MARK: Header
                List(content: {
                    VStack(alignment:.leading){
                        Text("ID:\(commande.id)")
                        Text("date : \(commande.date_)")
                        Text("Client : \(user.name)")
                        Text("Adresse : \(Text("\(user.adress)").underline())")
                            .onTapGesture(perform: {
                                UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?ll=\(user.loc_lat),\(user.loc_lon)")! as URL)
                            })
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textCase(.uppercase)
                    .foregroundStyle(.gray)
                    .font(.caption)
                    
                    Section("Informations de commandes") {
                        VStack(alignment:.leading){
                            Text("\(price.formatted(.currency(code: "EUR")))")
                                .font(.largeTitle)
                                .overlay(alignment: .topTrailing) {
                                    Text("Sous-Total")
                                        .font(.custom("Ubuntu", size: 10))
                                        .offset(x:20,y:-10)
                                        .multilineTextAlignment(.leading)
                                }
                            //MARK: If price has changed
                            if !(price != commande.sub_total){
                                Text("Avant: \(commande.sub_total.formatted(.currency(code: "EUR")))")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                            //MARK: More infos
                            Group {
                                Text("+\(commande.delivery.formatted())€ \(Text("(Livraison)").italic())")
                                    .foregroundStyle(.gray)
                                Text("-\(commande.discount.formatted())€ \(Text("(Coupon)").italic())")
                                    .foregroundStyle(.green)
                            }
                            .font(.footnote)
                            let total = commande.delivery + price - commande.discount
                            Text("Total: \(total.formatted())€")
                        
                            
                            Text(commande.infos)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .frame(maxWidth: .infinity, alignment:.leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .fill(.bar)
                                }
                        }
                        .frame(maxWidth: .infinity, alignment:.leading)
                            
                    }
                    
                    Section("Panier") {
                        ForEach(panier.sorted(by: {$0.service.name < $1.service.name}), id: \.self) {
                            achat in
                            // Line
                            HStack{
                                Text(achat.service.name)
                                    Spacer(minLength: 100)
                                Text("\(achat.quantity)")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true){
                                Button("Ajouter") {
                                    //MARK: add article
                                    panier.remove(achat)
                                    panier.insert(achat.increase())
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true){
                                Button("Retirer") {
                                    //MARK: remove 1 article unit
                                    panier.remove(achat)
                                    panier.insert(achat.decrease())
                                }
                                .tint(.red)
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                Button("Supprimer"){
                                    panier.remove(achat)
                                }
                            }))
                        }
                        //MARK: Line to add article in cart
                        
                        HStack{
                            //available article which aren't in the cart
                            Picker("Ajouter un article", selection: $newPurchase) {
                                ForEach(availablesArticle, id: \.self) { purchase in
                                    Text(purchase.name).tag(Achat(purchase, 1))
                                }
                            }
                            //MARK: Since 3 is the default value when we create a purchase and no service with id 3 exist
                            if newPurchase.service.id != 3 {
                                Button("Ajouter"){
                                    panier.insert(newPurchase)
                                    AvailablesArticlesUpdate()
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                            }
                            
                        }
                        .disabled(availablesArticle.isEmpty)
                       
                    }
                    
                    Section("Dates"){
                        VStack(alignment: .leading) {
                            HStack{
                                DatePicker(selection: $newDateIn,displayedComponents: [.date], label: { Text("Récupération") })
                                        .datePickerStyle(.compact)
                                        .onChange(of: newDateIn) { V in
                                            Task{
                                                let dateString = V.mySQLFormat()
                                                commande.enter_date = dateString
                                                possibleTimesIn = await fetchModel.FetchTimes(day: dateString)
                                            }
                                            
                                        }
                                //Time selection
                                if !possibleTimesIn.isEmpty{
                                    Picker(selection: $commande.enter_time, label: Text("Picker").minimumScaleFactor(0.5)) {
                                        ForEach(possibleTimesIn, id: \.self) { time in
                                            Text("\(time)-\(time+1)h").tag("\(time)")
                                        }
                                    }
                                    .labelsHidden()
                                }
                               
                            }
                            HStack{
                                DatePicker(selection: $newDateOut,displayedComponents: [.date], label: { Text("Livraison") })
                                    .datePickerStyle(.compact)
                                    .onChange(of: newDateOut) { V in
                                        Task{
                                            let dateString = V.mySQLFormat()
                                            commande.return_date = dateString
                                            possibleTimesOut = await fetchModel.FetchTimes(day: dateString)
                                        }
                                    }
                                //Time selection
                                if !possibleTimesOut.isEmpty{
                                    Picker(selection: $commande.return_time, label: Text("Picker").minimumScaleFactor(0.5)) {
                                        ForEach(possibleTimesOut, id: \.self) { time in
                                            Text("\(time)-\(time+1)h").tag("\(time)")
                                        }
                                    }
                                    .labelsHidden()
                                }
                            }
                            
                        }
                        .frame(maxWidth: .infinity, minHeight:100)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.bar)
                        }
                    }
                })
               
                .overlay(alignment: .bottomTrailing, content: {
                    Button("Mettre à jour"){
                        //Send command
                        Task{
                            //MARK: Update this command
                            //for service_quantity message
                            commande.services_quantity = userdata.cartToString(panier)
                            commande.sub_total = price
                            let result = await commande.Update()
                            if result{
                                show = false
                                alerte.NewNotification(.amber, "Commande modifiée avec succès", UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.green))
                                
                            }
                        }
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .disabled(price == commande.sub_total)
                })
                .overlay(alignment: .topTrailing, content: {
                    Button {
                        //Close the view
                        commande = Command()
                        withAnimation {
                            show = false
                        }
                    } label: {
                        Image(systemName: "xmark.app.fill")
                            .resizable()
                            .aspectRatio(contentMode: ContentMode.fit)
                            .frame(width: 30)
                    }
                    .padding()
                    .tint(.secondary)

                })
        //.background(.thinMaterial)
        //.background(_command.STATUS_COMMAND == "Sent" ? .blue.opacity(0.3) : .red.opacity(0.1))
                .listStyle(.plain)
                .preferredColorScheme(.dark)
        .onChange(of: panier, perform: { value in
            PriceUpdate()
        })
        
        .onAppear{
            Task{
                user = utilisateur.userWithId(commande.user ?? 0)
                let _ = await article.fetch()
                DispatchQueue.main.async{
                    //self.all_services_local = t
                }
                //modif_condition = userdata.hoursBetween(userdata.dateTime,commande.this.enter_date.toDate(), 48)
                panier = commande.ReadCommand(article)
                newDateIn = commande.enter_date.toDate()
                newDateOut = commande.return_date.toDate()
                //fetchModel.fetchSewing()
                userdata.taskbar = false
                //date_in = commande.this.enter_date.toDate()
                //MARK: Get price first
                PriceUpdate()
                AvailablesArticlesUpdate()
                newPurchase = Achat(availablesArticle.first!, 0)
            }
            
        }
    }
    func AvailablesArticlesUpdate(){
        availablesArticle = article.all.filter{element in
            !panier.contains(where: {$0.service == element})}
            .sorted(by: {$0.name < $1.name})
    }
    
    /// Function to update the price of a cart
    func PriceUpdate(){
        price = Decimal()
        panier.forEach ({
            let element = $0
            price += Decimal(element.quantity) * element.service.cost
        })
    }
}




struct CommandDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommandDetailView(commande: Command(_i: 5), show: .constant(true))
            .environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Article())
            .environmentObject(Utilisateur())
            .environmentObject(Alerte())
    }
}

