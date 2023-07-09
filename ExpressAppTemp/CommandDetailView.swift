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
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var panier:Panier
    @EnvironmentObject var article:Article
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var alerte:Alerte
    @State var all_services_local:[Int:Service]=[:]
    @State var showStatevalues:Bool = false
    @State var date_in = Date()
    @State var date_out = Date()
    @State var modif_condition:Bool = false
    @State var _cart:[Service:Int]=[:]
    @State var add_to_command:Bool = false
    @State var nouvelAchat:Achat = Achat(Service(), 0)
    var body: some View {
        GeometryReader { GeometryProxy in
            ScrollView{
                Text("Commande : #\(commande.this.id)")
                    .font(.custom("Ubuntu", size: 30))
                    .padding(.top,50)
                Text("\(commande.this.date_)")
                    .font(.caption)
                    .opacity(0.7)
                //Total de la commande
                
                Text("Total de la commande")
                    .font(.caption)
                    .padding(.top)
                Text("\(commande.this.cost.formatted(.currency(code: "EUR")))")
                    .font(.custom("Ubuntu", size: 40))
                
                VStack{
                    //Command List
                    ScrollView(.horizontal){
                        LazyHGrid(rows: [GridItem(.flexible())]){
                            // Plus button to add to the cart
                            Section {
                                //Command articles
                                ForEach(commande.services.sorted(by: {$0.quantity < $1.quantity}), id: \.self) { achat in
                                        VStack(alignment:.center){
                                            Image(uiImage: (article.images[achat.service.illustration] ?? UIImage(named: "logo120"))!)
                                                .resizable()
                                                .clipped()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                            VStack{
                                                Text("\(achat.service.name)")
                                                    .multilineTextAlignment(.leading)
                                                Text("\(achat.quantity)")
                                            }
                                            .font(.caption2)
                                            //Add and remove buttons
                                            HStack{
                                                //Add button
                                                Button {
                                                    commande.increase(achat)
                                                } label: {
                                                    Image(systemName: "plus.app.fill")
                                                }
                                                
                                                //Add button
                                                Button {
                                                    commande.decrease(achat)
                                                } label: {
                                                    Image(systemName: "minus.square.fill")
                                                }
                                            }
                                        }
                                        .padding()
                                        .background()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                            }
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.never)
                    
                    // Add article to commande part
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                        Picker(selection: $nouvelAchat.service) {
                            ForEach(article.articleOutOfCart(commande.services).sorted(by: {$0.service.id < $1.service.id}), id: \.self) { service in
                                Text(service.service.name).tag(service.service)
                                    .clipped()
                            }
                        } label: {
                            Text("Nouvel article")
                        }
                        .padding()
                        .background(.bar)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: RoundedCornerStyle.continuous))
                        // quantities
                        TextField(text: .init(get: {
                            String(nouvelAchat.quantity)
                        }, set: { Value in
                            nouvelAchat.quantity = Int(Value) ?? 0
                        })) {
                            // label
                            Text("Quantité")
                        }
                        .keyboardType(.numberPad)
                        .padding()
                        .background(.bar)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: RoundedCornerStyle.continuous))
                        
                        // Validate Button
                        Button {
                            // add New article to cart
                            commande.toCart(nouvelAchat)
                        } label: {
                            Text("OK")
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                    
                    // Shipping and recover dates
                    #warning("A rectifier pour couvrir les bonnes périodes")
                    /*
                    Group {
                        //Recuperation
                        VStack{
                            Label("Récupération", systemImage: "shippingbox.fill")
                            if modif_condition{
                                HStack{
                                    DatePicker(
                                        "Start Date",
                                        selection: $date_in,
                                        in:userdata.dateTime ... Date.distantFuture,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color("xpress"))
                                    .cornerRadius(20)
                                    
                                    Picker(selection: $commande.this.enter_time) {
                                        ForEach(fetchModel.TIMES_IN_AVAILABLES, id: \.self) { value in
                                            Text("\(value)h à \(value + 1)h").tag("\(value)")
                                            
                                        }
                                    } label: {
                                        Text("Horaire")
                                    }
                                    .pickerStyle(.menu)
                                    .background(.ultraThinMaterial)
                                    .background(Color("xpress").opacity(0.3))
                                    .shadow(radius: 1)
                                    .cornerRadius(20)
                                }
                                .onChange(of: date_in) { _ in
                                    Task{
                                        await fetchModel.FetchTimes(day:date_in.mySQLFormat(), type:"in")
                                        commande.setDateIn(date_in)
                                        commande.setDateOut(fetchModel.AddDaysToDate(date: date_in, daysToAdd: panier.daysNeeded()))
                                       
                                        //userdata.currentCommand.return_date = fetchmodel.AddDaysToDate(date: date, daysToAdd: userdata.MaxDaysForCard()).mySQLFormat()
                                        //userdata.currentCommand.return_date = return_date.mySQLFormat()
                                    }
                                    
                                }
                            }
                            
                            
                            Label("\(commande.this.enter_date.toDate()) entre \(commande.this.enter_time)H et \(Int(commande.this.enter_time)! + 1)H", systemImage: "info")
                                .font(.caption2)
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        
                        //Delivery
                        VStack{
                            Label("Livraison", systemImage: "shippingbox.and.arrow.backward.fill")
                            if modif_condition{
                                HStack{
                                    DatePicker(
                                        "Start Date",
                                        selection: $date_out,
                                        //in:fetchModel.AddDaysToDate(date: date_in, daysToAdd:userdata.MaxDaysForCard()) ... Date.distantFuture,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color("xpress"))
                                    .cornerRadius(20)
                                    
                                    Picker(selection: $commande.this.return_time) {
                                        ForEach(fetchModel.TIMES_OUT_AVAILABLES, id: \.self) { value in
                                            Text("\(value)h à \(value + 1)h").tag("\(value)")
                                            
                                        }
                                    } label: {
                                        Text("Horaire")
                                    }
                                    .pickerStyle(.menu)
                                    .background(.ultraThinMaterial)
                                    .background(Color("xpress").opacity(0.3))
                                    .shadow(radius: 1)
                                    .cornerRadius(20)
                                }
                            }
                            
                        }
                        .onChange(of: date_out) { _ in
                            Task{
                                await fetchModel.FetchTimes(day:date_out.mySQLFormat(), type:"out")
                                commande.setDateOut(date_out)
                                //userdata.currentCommand.return_date = fetchmodel.AddDaysToDate(date: date, daysToAdd: userdata.MaxDaysForCard()).mySQLFormat()
                                //userdata.currentCommand.return_date = return_date.mySQLFormat()
                            }
                        }
                    }*/
                    VStack{
                        Label("Récupération de la commande le \(commande.this.enter_date.toDate().dateUserfriendly()) entre \(commande.this.enter_time)H et \(Int(commande.this.enter_time)! + 1)H", systemImage: "info")
                            .font(.caption2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .border(Color("xpress").gradient, width: 5)
                    .padding()
                    
                    VStack{
                        Label("Retour de la commande le \(commande.this.return_date.toDate().dateUserfriendly()) entre \(commande.this.return_time)H et \(Int(commande.this.return_time)! + 1)H", systemImage: "info")
                            .font(.caption2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .border(Color.red.gradient, width: 5)
                    .padding()
                    
                    
                    //Client infos
                    VStack{
                        Text("Contact client")
                        if commande.this.infos.isEmpty{
                            // adresse et contacts du client
                            let client = utilisateur.userWithId(commande.this.user!)
                            Text(client.name)
                                .font(.title)
                            Text(client.adress)
                                .font(.title2)
                            Text(client.mail)
                                .font(.caption)
                            Text(client.phone)
                                .font(.caption)
                        }else{
                            Text(commande.this.infos)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background{
                        Image(systemName: "location")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("xpress").opacity(0.5), Color.secondary.opacity(0.5))
                    }
                    .background(Color("xpress").opacity(0.5).gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    .background(.bar)
                    .onTapGesture {
                        let client = utilisateur.userWithId(commande.this.user!)
                        if commande.this.infos.isEmpty{
                            UIPasteboard.general.string = client.adress
                        }else{
                            UIPasteboard.general.string = commande.this.infos
                        }
                        
                        // Alert
                        //Show notification
                        alerte.this.text = "Adresse copiée"
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            alerte.this.text = String()
                        })
                        
                    }
                    Text("tapez pour copier l'adresse")
                        .font(.caption2)
                        .offset(y:-20)
                      
                        //.foregroundColor(Color.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment:.top)
            
            //header
            VStack(alignment:.center){
                //back & save buttons
                HStack{
                    //back
                    Button {
                        withAnimation {
                            //show_this = false
                            commande.erase()
                            commande.editModeOff()
                        }
                    } label: {
                        Label("retour", systemImage: "arrowshape.backward.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    
                    //edit button
                    if commande.this.isEditable{
                        Button {
                            Task{
                                commande.this.services_quantity = commande.CartToString
                                let response = await commande.Put_Command()
                                if response{
                                    commande.erase()
                                    commande.editModeOff()
                                }
                            }
                        } label: {
                            Label("Mettre à jour", systemImage:"square.and.pencil")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                    
                    

                }
                .padding()
            }
            .frame( maxWidth:.infinity  , maxHeight: 50, alignment: Alignment.center)
            .background(.bar)
            
            //Add element to the command
            /*
            if add_to_command{
                Add_Article_to_COMMAND(_show_this: $add_to_command, cart: $_cart)
            }*/
            
            if commande.isEmpty{
                //vue de chargement
                VStack{
                    LoadingView()
                        .overlay(alignment: .center) {
                            Text("Chargement de la commande")
                                .font(.custom("Ubuntu", size:20))
                                .offset(y:100)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
        //.background(.thinMaterial)
        //.background(_command.STATUS_COMMAND == "Sent" ? .blue.opacity(0.3) : .red.opacity(0.1))
        .background(.ultraThinMaterial)
        
        .onAppear{
            Task{
                
                //var t = await fetchModel.FetchServices()
                DispatchQueue.main.async{
                    //self.all_services_local = t
                }
                print(self.all_services_local)
                modif_condition = userdata.hoursBetween(userdata.dateTime,commande.this.enter_date.toDate(), 48)
                
                //fetchModel.fetchSewing()
                userdata.taskbar = false
                date_in = commande.this.enter_date.toDate()
                //let r = await fetchModel.Message_to_Cart_review(message: userdata.currentCommand.services_quantity)
                
                
            }
        }
        
    }
    func Decode_message(_message:String)->[Service:Int]{
        var r : [Service:Int]=[:]
        print(fetchModel.all_services)
        _message.split(separator: ",").forEach({
            _article in
            let _service_id = Int(_article.split(separator: ":").first!)!
            let _quantity = Int(_article.split(separator: ":").last!)!
            print(fetchModel.all_services)
            if !fetchModel.all_services.isEmpty{
                let _service = fetchModel.all_services[_service_id]
                r[_service!] = _quantity
            }
        })
        return r
    }
}



struct CommandDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommandDetailView(
            date_in: Date(),
            date_out: Date()
        ).environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Panier())
            .environmentObject(Commande())
            .environmentObject(Article())
            .environmentObject(Utilisateur())
            .environmentObject(Alerte())
    }
}

