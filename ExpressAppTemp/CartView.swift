//
//  CartView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//
import Foundation
import SwiftUI
import UIKit
import MapKit
import AVFoundation

extension Date{
    func formatDate()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        return dateformater.string(from: self)
    }
    func dateUserfriendly()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "EEEE dd MMMM YYYY"
        return dateformater.string(from: self)
    }
    
    func mySQLFormat()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy/MM/dd"
        return dateformater.string(from: self)
    }
    func dribbleStyle()->String{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy.MM.dd"
        return dateformater.string(from: self)
    }
}

let dateRange: ClosedRange<Date> = {
    let calendar = Calendar.current
    let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    let endComponents = DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59)
    return calendar.date(from: startComponents)!
        ...
        calendar.date(from:endComponents)!
}()



let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
}()
struct CartView: View {
    @State var pass1:Bool = false
    @State var valueChange:Bool = false
    @State var buttonPush:Bool = false
    @State var notification:Bool = false
    @EnvironmentObject var userdata:UserData
    @State var dateAndTimeShow:Bool = false
    @State var servicename = ""
    @EnvironmentObject var fetchmodel : FetchModels
    @State var date: Date = Date.init()
    @State var return_date: Date = Date.init()
    @State var hour: String = "hour hour"
    @State var adressModifier:Bool = false
    @State var commandSended:Bool = false
    //@State var newCommand:COMMAND = COMMAND.init(user: 0)
    @Namespace var namespace:Namespace.ID
    @State var ValidateCommand:Bool = false
    @State var newCommandID:Int64 = 0
    @State var selectedNumber = 1
    @State var stage = 1
    @State var promoCode=""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    //test
    @State var cartTest : [Service:Int] = [Service.init():1]
    @State var confirmation:Bool = false
    @State private var vStackHeight: CGFloat = 0
    @State var selectedTime:String = String.init()
    @State var shipping_validation:Bool = false
    @State var returnDate_choice:Bool = false
    //Adress Modifiers========================================
    @State var adress_validation:Bool = false
    @State var adress_road:String=String.init()
    @State var adress_number:String=String.init()
    @State var adress_number_sup:String=String.init()
    @State var adress_cp:String=String.init()
    @State var adress_city:String=String.init()
    //========================================================
    @State var show_cart:Bool = false
    @State var show_recup:Bool = false
    @State var show_ship:Bool = false
    @State var show_adress:Bool = false
    @State var coupon_value:String = String.init()
    var body: some View {
        GeometryReader {Proxy in
            let _ = Proxy.size
            let _:CGFloat = Proxy.frame(in: .named("scroll")).minY
            if userdata.cart.isEmpty{
              
                    Text("Panier vide")
                        .font(.custom("Ubuntu", size: 40, relativeTo: .title))
                        .shadow(radius: 10)
                        .frame(maxWidth: .infinity, maxHeight:.infinity)
                
            }else{
                // If cart is not empty, show cart
                List {
                    //List of articles in the cart
                    Section {
                        
                        if show_cart{
                            CartCommand()
                        }
                        
                    }
                header: {
                        HStack{
                            Image(systemName: userdata.cart.isEmpty ? "exclamationmark.circle" : "checkmark.circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(userdata.cart.isEmpty ? Color.red : Color.green)
                                .frame(width: 20)
                                .padding(.horizontal)
                                
                            Spacer()
                            VStack(spacing:2) {
                                Text("List")
                                Text("\(userdata.cart.count) articles")
                                    .font(.caption)
                            }
                            Spacer()
                            
                        }
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight:50)
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation (.spring()){
                                    show_cart.toggle()
                                }
                                
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: !show_cart ? "arrowtriangle.right.fill" : "arrowtriangle.down.fill")
                                    .padding(.trailing, 20)
                            }
                    }
                    
                    //user adress that it can be modify
                    Section {
                        if show_adress{
                            VStack(alignment:.leading, spacing: 20){
                                TextField("Rue",text: $adress_road)
                                TextField("Numéro", text:$adress_number)
                                    .keyboardType(.numberPad)
                                TextField("Supplément", text:$adress_number_sup)
                                TextField("Ville", text:$adress_city)
                                TextField("Code Postal",text:$adress_cp)

                            }.padding()
                                .font(.custom("Ubuntu", size: 26))
                        }
                        
                    }
                header: {
                        HStack{
                            Image(systemName: userdata.CheckAddress() ? "checkmark.circle.fill" : "exclamationmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .padding(.horizontal)
                                .foregroundColor(userdata.CheckAddress() ? Color.green : Color.red)
                            Spacer()
                            VStack(spacing:2) {
                                Text("Adresse")
                                Text("\(userdata.currentUser.adress)")
                                    .font(.caption)
                            }
                            Spacer()
                            
                        }
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight:50)
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation (.spring()){
                                    show_adress.toggle()
                                }
                                
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: !show_adress ? "arrowtriangle.right.fill" : "arrowtriangle.down.fill")
                                    .padding(.trailing, 20)
                            }
                    }
                
                    //Recup menu
                    Section {
                        /*
                        if show_recup{
                            RecoverDate()
                        }
                        */
                    }
                header: {
                        HStack{
                            Image(systemName: userdata.CheckRecoverDate() ? "checkmark.circle.fill" : "exclamationmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .padding(.horizontal)
                                .foregroundColor( userdata.CheckRecoverDate() ? Color.green : Color.red)
                            Spacer()
                            VStack(spacing:0){
                                Text("Récupération")
                                Text("\(userdata.currentCommand.enter_date)")
                                    .font(.caption2)
                            }
                            Spacer()
                            
                        }
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight:50)
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation (.spring()){
                                    show_recup.toggle()
                                }
                                
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: !show_recup ? "arrowtriangle.right.fill" : "arrowtriangle.down.fill")
                                    .padding(.trailing, 20)
                            }
                    }
                footer:{
                        Text("Tapez pour choisir une date de récupération")
                            .font(.caption)
                            .opacity(0.8)
                    }

                    //Shipping menu
                    Section {
                        /*
                        if show_ship{
                            ShippingDate()
                        }
                        */
                    }
                header: {
                        HStack{
                            Image(systemName: userdata.CheckShippingDate() ? "checkmark.circle.fill" : "exclamationmark.circle" )
                                .resizable()
                                .scaledToFit()
                                .foregroundColor( userdata.CheckShippingDate() ? Color.green : Color.red)
                                .frame(width: 20)
                                .padding(.horizontal)
                            Spacer()
                            VStack(spacing:0){
                                Text("Livraison")
                                Text("\(userdata.currentCommand.return_date)")
                                    .font(.caption2)
                                    //.font(.caption)
                            }
                            Spacer()
                            
                        }
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight:50)
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation (.spring()){
                                    show_ship.toggle()
                                }
                                
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: !show_ship ? "arrowtriangle.right.fill" : "arrowtriangle.down.fill")
                                    .padding(.trailing, 20)
                            }
                    }
                footer:{
                    Text("La livraison est prévue au \(userdata.currentCommand.return_date) . Tapez pour choisir un horaire")
                            .font(.caption)
                            .opacity(0.8)
                            
                    }
                    //PromoCode
                    Section {
                        HStack{
                            TextField("", text: $promoCode)
                                .textCase(.uppercase)
                                .autocapitalization(UIKit.UITextAutocapitalizationType.allCharacters)
                            Button("Appliquer"){
                                Task{
                                    coupon_value = await userdata.Check_Coupon(Coupon(promoCode, Decimal(0.00)))
                                }
                            }
                                .buttonStyle(.borderless)
                        }
                        .padding(.horizontal)
                        .padding()
                        .background(.thickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                header: {
                        Text("Code Promo")
                            .font(.title3.bold())
                    }
                footer: {
                    //If promocode is correct
                        Label("\(coupon_value)", systemImage: "checkmark.circle")
                            .foregroundColor(.green)
                    
                }
                    .padding(.horizontal)
                }
                .listStyle(.insetGrouped)
            }

        }
            .coordinateSpace(name: "scroll")
            .background(.ultraThinMaterial)
            //Set off autoUppercase
            .textInputAutocapitalization(TextInputAutocapitalization.sentences)
            
            .sheet(isPresented: $confirmation, onDismiss: {
                Task{
                    confirmation.toggle()
                    stage = 1
                    userdata.cart.removeAll()
                    userdata.GoToPage(goto: "accueil")
                    userdata.taskbar = true
                }
            }) {
                if #available(iOS 16.0, *) {
                    VStack{
                        Text("Confirmation de commande")
                            .font(.title3).bold()
                            .padding()
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
                        
                        //Order number
                        Text("Numéro de commande : \(userdata.currentCommand.id)")
                            .font(.custom("Ubuntu", size: 20))
                            .foregroundColor(.gray)
                            .padding(.vertical, 15)
                        
                        
                            List {
                                Section {
                                    ForEach(userdata.cart.keys.sorted(by: {$0.time < $1.time}), id: \.self) {
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
                                               "QTE:\(userdata.cart[service] ?? 0)"
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

                                
                            }
                            .listStyle(.grouped)
                            .background(.ultraThinMaterial)
                    }.frame(alignment: .center)
                        .presentationDetents([.large])
                    
                        .overlay(alignment:.bottom){
                            
                            Button {
                                //Checkout action
                                Task{
                                    confirmation.toggle()
                                    stage = 1
                                    userdata.cart.removeAll()
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
                } else {
                    // Fallback on earlier versions
                }
            }
            
            .onAppear{
                //On appear, fill the adress entries if it's correct
                let OldAdress = fetchmodel.Uncat_Adress(address: userdata.currentUser.adress)
                
                if !OldAdress.isEmpty{
                    adress_road = OldAdress[0]
                    adress_number = OldAdress[1]
                    adress_cp = OldAdress[3]
                    adress_city = OldAdress[4]
                }
                
                //Hide taskba if cart is not empty
                if !userdata.cart.isEmpty{
                    userdata.taskbar = false
                }
            }
            .onDisappear{
                withAnimation(.spring()){
                    userdata.taskbar = true
                }
            }
            .onChange(of: adress_road) { V in
                userdata.currentUser.adress = fetchmodel.Concat_Adress(adress: adress_road, number: adress_number, ext: adress_number_sup, postal_code: adress_cp, city: adress_city)
            }
            .onChange(of: adress_number) { V in
                userdata.currentUser.adress = fetchmodel.Concat_Adress(adress: adress_road, number: adress_number, ext: adress_number_sup, postal_code: adress_cp, city: adress_city)
            }
        
            .onChange(of: adress_cp) { V in
                userdata.currentUser.adress = fetchmodel.Concat_Adress(adress: adress_road, number: adress_number, ext: adress_number_sup, postal_code: adress_cp, city: adress_city)
            }
            .onChange(of: adress_city) { V in
                userdata.currentUser.adress = fetchmodel.Concat_Adress(adress: adress_road, number: adress_number, ext: adress_number_sup, postal_code: adress_cp, city: adress_city)
            }
            .onChange(of: adress_number_sup) { V in
                userdata.currentUser.adress = fetchmodel.Concat_Adress(adress: adress_road, number: adress_number, ext: adress_number_sup, postal_code: adress_cp, city: adress_city)
            }
        
        //Finally the button to achieve the command
            .overlay(alignment:.bottom){
                HStack{
                    if (!userdata.cart.isEmpty){
                        VStack(alignment: .leading, spacing: 10) {
                            //commands subtotals
                            VStack(alignment: .leading, spacing: 5) {
                                //sous total
                                HStack{
                                    Text("Sous-total")
                                        .opacity(0.7)
                                    Spacer()
                                    Text((userdata.currentCommand.sub_total ).formatted(.currency(code: "EUR")))
                                }
                                
                                //Shipping Cost
                                HStack{
                                    Text("Livraison")
                                        .opacity(0.7)
                                    Spacer()
                                    Text((userdata.currentCommand.delivery).formatted(.currency(code: "EUR")))
                                }
                                //Dicount code reduction
                                HStack{
                                    Text("Réduction ()")
                                        .opacity(0.7)
                                    Spacer()
                                    Text((userdata.currentCommand.discount).formatted(.currency(code: "EUR")))
                                }
                                .padding(.bottom, 10)
                            }
                            Button {
                                Task {
                                    //Set command
                                    userdata.currentCommand.cost = userdata.CommandCost()
                                    
                                    userdata.currentCommand.user = userdata.currentUser.id
                                    userdata.currentCommand.services_quantity = userdata.cartToString(userdata.cart)
                                    //userdata.currentCommand.enter_date = date.mySQLFormat()
                                    //userdata.currentCommand.return_date = date.addingTimeInterval(TimeInterval(5*24*60*60)).mySQLFormat()
                                    //confirmation = await fetchmodel.PushCommand(commande: userdata.currentCommand)
                                    userdata.cart.removeAll()
                                }
                            } label: {
                                Text("Total")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Text((userdata.CommandCost()).formatted(.currency(code: "EUR")))
                                    .font(.title2)
                                    .bold()
                            }

                            //.colorInvert()
                            
                            .padding()
                            .background(Color("xpress").opacity(0.5))
                            .clipShape(Capsule())
                            .padding(.horizontal)
                            .coordinateSpace(name: "taskbar")
                            
                            .disabled(
                                // true if the button shoul be disabled
                                // then we return true if at least one of verif is egal to false
                                !userdata.CheckRecoverDate()
                                ||
                                !userdata.CheckShippingDate()
                                ||
                                !userdata.CheckAddress()
                            )
                        }
                        //Change the navBar if we are in cart
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding(.horizontal)
            }

    }
    //Commande
    
    @ViewBuilder
    func CartCommand() -> some View{
        //Commande
        
            ForEach(userdata.cart.keys.sorted(by: {$0.time < $1.time}), id: \.self) {
                service in
                withAnimation(.spring()){
                    HStack{
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                //quantity -= quantity > 0 ? 1 : 0
                                userdata.RemoveServiceFromCart(s: service)
                            }
                            AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(service.name)") , content: { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                                    
                                    
                            }, placeholder: {
                                ProgressView()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            })
                            .matchedGeometryEffect(id: "\(service.name)", in: namespace)
                            VStack(alignment: .leading){
                                //Infos d'article
                                Text("\(service.name)")
                                    .font(.title2).bold()
                                Text("\(userdata.cart[service] ?? 0)").font(.callout).bold()
                                    .colorInvert()
                                    .background(.blue.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                //prix unitaire
                                Text("\((service.cost).formatted(.currency(code: "EUR")))").font(.title3).bold()
                                
                            }
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                userdata.AddServiceToCart(s: service)
                            }
                        }
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(maxWidth:.infinity, maxHeight: 50)
                        .shadow(radius: 2)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                
                            } label: {
                                Image(systemName: "xmark.bin.fill")
                            }
                            .tint(.red)

                        }
                    }
                }
        
        
    }
    
    //Adress
    @ViewBuilder
    func DeliveryAddress(size:CGSize) -> some View{
        VStack{
            Text("Addresse de livraison")
                .font(.title2).bold().padding(.horizontal, 10)
                .frame(width: size.width, alignment: .leading)
          
                HStack() {
                    Text("Rue des alliés 93 1090 Bruxelles")
                        .font(.custom("Ubuntu", size: 20, relativeTo: .title2))
                        //.multilineTextAlignment(.leading)
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Modifier")
                    }
                    .buttonStyle(.bordered)
                }
                .shadow(radius: 20)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .frame(width:.infinity,height: 100)
                        .padding()
                        
                        
                }
                .padding()
        }
        
    }
    
    //shipping date
    @State private var selectedHourIn = 9
    @State private var selectedHourOut = 10

    
   
    //Fonction qui calcule le tarif total
    func TotalCost () -> Decimal{
        var total:Decimal = 0
        userdata.currentServiceHasCommand.forEach { index in
            total += fetchmodel.GetNameByID(sewingid: Int(index.service_ID_SERVICE)).cost * Decimal(index.quantity)
        }
        return total
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView().environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}
