//
//  Cart.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/04/2023.
//

import SwiftUI


/// Cart User View. Here is just the cart. Other components have their own view
struct Cart: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var fetchmodel : FetchModels
    @EnvironmentObject var panier:Panier
    @EnvironmentObject var coupon:Coupons
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var article:Article
    @EnvironmentObject var utilisateur:Utilisateur
    @Environment(\.colorScheme) var colorscheme
    @State var confirmation:Bool=false
    @State var cartPage:Int=0
    @State var datePage:Int=1
    @State var update_value:Bool=true
    @State var presentation_detent_default = PresentationDetent.medium
    @State var command_id_after_check:Int = Int()
    @State var shippingDetails:Bool=false;
    var body: some View {
        GeometryReader { GeometryProxy in
                ScrollView{
                    Rectangle()
                        .frame(height: 0)
                        .foregroundStyle(.clear)
                        .padding(.top, 120)
                    Section {
                        
                        ForEach(commande.services.sorted(by: {$0.service.id < $1.service.id}), id: \.self) { achat in
                            // Entry of the cart
                            // remove, decrease, increase in commande
                            VStack{
                                HStack(alignment:.top){
                                    Image(uiImage: (article.images[achat.service.illustration] ?? UIImage(named: "logo120"))!)
                                        .resizable()
                                        .frame(width: 80, height:80)
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(10)
                                        .background(.bar)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    VStack(alignment:.leading,spacing:0){
                                        Text(achat.service.name)
                                            .font(.custom("Ubuntu", size: 20))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .bold()
                                        //MARK: Get categories for the service and show them
                                        HStack{
                                            ForEach(achat.service.categories.split(separator: ";", maxSplits: 3, omittingEmptySubsequences: true), id:\.self) { category in
                                                Text(category)
                                                    .font(.caption)
                                            }
                                        }
                                        //Cost
                                        Text(achat.service.cost.formatted(.currency(code:"EUR")))
                                            .font(.custom("Ubuntu", size: 10))
                                            
                                        Spacer()
                                        HStack{
                                            //Quantity & buttons
                                            Image(systemName: "minus")
                                                .padding()
                                                .background(.bar)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .scaleEffect(0.5)
                                                .onTapGesture {
                                                    withAnimation {
                                                        commande.decrease(achat)
                                                    }
                                                }
                                            //Quantity
                                            Text("\(achat.quantity)")
                                                .font(.custom("BebasNeue", size: 15))
                                            Image(systemName: "plus")
                                                .padding()
                                                .background(.bar)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .scaleEffect(0.5)
                                                .onTapGesture {
                                                    withAnimation {
                                                        commande.increase(achat)
                                                    }
                                                }
                                            Spacer()
                                            //Delete button
                                            Image(systemName: "bin.xmark.fill")
                                                .padding(.horizontal)
                                                .onTapGesture {
                                                    withAnimation {
                                                        commande.remove(achat)
                                                    }
                                                }
                                        }
                                    }
                                   
                                }
                                //MARK: Custom Divider
                                Rectangle()
                                    .fill(LinearGradient(colors: [
                                        Color.primary.opacity(0),
                                        Color.primary.opacity(1),
                                        Color.primary.opacity(0)
                                    ], startPoint: .leading, endPoint: .trailing))
                                    .frame(maxWidth: .infinity, maxHeight:0.3)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    //MARK: Promo code
                    VStack{
                        HStack{
                            TextField("Coupon", text: .init(get: {
                                coupon.this.code
                            }, set: { Value in
                                coupon.this.code = Value
                            }))
                                .textCase(.uppercase)
                                .autocapitalization(UIKit.UITextAutocapitalizationType.allCharacters)
                                .padding()
                                .autocorrectionDisabled(true)
                                .background(.bar)
                                .overlay(alignment: .trailing) {
                                    VStack{
                                        Button{
                                            Task{
                                                commande.this.discount = await coupon.this.Check_Coupon()
                                            }
                                        }label: {
                                            Text("Appliquer")
                                                .font(.caption)
                                                .padding(7)
                                        }
                                        .buttonStyle(.borderless)
                                        .tint(Color("xpress"))
                                        .colorInvert()
                                    }
                                    .frame(maxHeight: .infinity)
                                    .background(Color("xpress"))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .frame(maxWidth: 200)
                        .padding(.horizontal,30)
                        .shadow(radius: 1)
                    }
                    .scaleEffect(commande.isEmpty ? 0 : 1)
                }
                
            
           // .blur(radius: userdata.cart.isEmpty ? 20 : 0)
            .task{
                //Hide taskbar if cart is not empty
                if !commande.services.isEmpty{
                    userdata.taskbar = false
                }
            }
            //Header
            HStack(alignment:.bottom){
                Image(systemName: "chevron.backward")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .onTapGesture {
                        withAnimation {
                            userdata.GoToPage(goto: "accueil")
                        }
                    }
                //.buttonBorderShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(alignment: .leading)
            .offset(y:50)
            .padding(.horizontal)
            VStack{
                VStack(alignment: .center, spacing: 20) {
                    Group{
                        //Sub-total
                        HStack(alignment: .center) {
                            Text("Sous-Total")
                            Spacer()
                            //Text(userdata.currentCommand.sub_total.formatted(.currency(code:"EUR")))
                            Text(commande.getCost.formatted(.currency(code: "EUR")))
                               .bold()
                        }
                        .padding(.horizontal)
                        
                        //Shipping cost
                        HStack(alignment: .center) {
                            Text("Frais livraison")
                            Spacer()
                            if (commande.this.delivery == 0.00){
                                Text("Calcul...")
                                    .foregroundStyle(.red)
                                    .italic()
                                    .onTapGesture(perform: {
                                        shippingDetails.toggle()
                                    })
                                    .alert("Nous reviendrons vers vous par email ou par appel pour fixer le prix de la livraison", isPresented: $shippingDetails, actions: {
                                        
                                    })
                            }else{
                                Text(commande.this.delivery.formatted(.currency(code: "EUR")))
                                    .bold()
                            }
                        }
                        .padding(.horizontal)
                        
                        //reduction
                        HStack(alignment: .center) {
                            Text("Reduction")
                            Spacer()
                            Text("-\(commande.this.discount.formatted(.currency(code: "EUR")))")
                                .bold()
                        }
                        .padding(.horizontal)
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                    HStack(alignment: .center) {
                        Text("Total")
                        Spacer()
                        Text(commande.TotalCost.formatted(.currency(code: "EUR")))
                            .bold()
                    }
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                
                    // Continue Button if price is greather than 30€
                
                    Button {
                        userdata.show_date_selector_view = true
                    } label: {
                        Text("Continuer")
                        .frame(maxWidth: .infinity)
                    }
                    .font(.title)
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 30)
                    .frame(height:commande.subTotal >= 30.0 ? 40 : 0)
                    .offset(y: commande.subTotal >= 30.0 ? 0 : 100)
                    .animation(.pulse(), value: commande.subTotal)
            }
            .padding()
            .background{
               RoundedRectangle(cornerRadius: 40)
                    .fill(.bar)
                    .shadow(radius: 10)
            }
            .padding()
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.bottom)
            .ignoresSafeArea(SafeAreaRegions.all)
            //get delivery cost
            .onAppear {
                Task{
                    commande.this.delivery =
                    await commande.getDeliveryCost(utilisateur.this)
                }
                
                
            }
            //.blur(radius: userdata.cart.isEmpty ? 20 : 0)
            
            if userdata.show_date_selector_view{
                Date_selector_View(show: $userdata.show_date_selector_view)
            }
            
            //if cart is empty, print it
            if commande.isEmpty{
                VStack(alignment: .center, spacing: 20) {
                    Image("empty")
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 5)
                        
                    Text("Panier Vide")
                        .font(.custom("BebasNeue", size: 100))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                    
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity, alignment:.top)
                .background(Color("xpress").gradient)
            }
        }
        .frame(alignment: .bottom)
        
        //Background
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
        .background{
            RadialGradient(colors: [
                colorscheme == .dark ? Color("xpress") : Color("xpress"),
                colorscheme == .dark ? Color("xpress").opacity(0.2) : Color("xpress").opacity(0.2)
            ], center: .bottom, startRadius: 50, endRadius: 300)
        }
    }
    
}

struct Cart_Previews: PreviewProvider {
    static var previews: some View {
        Cart().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Panier())
            .environmentObject(Coupons())
            .environmentObject(Commande())
            .environmentObject(Utilisateur())
    }
}
