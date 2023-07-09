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
    @State var confirmation:Bool=false
    @State var cartPage:Int=0
    @State var datePage:Int=1
    @State var update_value:Bool=true
    @State var presentation_detent_default = PresentationDetent.medium
    @State var command_id_after_check:Int = Int()
    var body: some View {
        GeometryReader { GeometryProxy in
            VStack{
                List{
                    Section {
                        ForEach(commande.services.sorted(by: {$0.service.id < $1.service.id}), id: \.self) { s in
                            // Entry of the cart
                            HStack(alignment:.bottom){
                                // Image of the service
                                Image(uiImage: (article.images[s.service.illustration] ?? UIImage(named: "logo120"))!)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                                
                                //Name of the servive and quantity up and downdable
                                VStack(alignment: .leading, spacing: 20) {
                                    Text(s.service.name)
                                        .bold()
                                    
                                    //quantity and buttons
                                    HStack(alignment: .bottom, spacing: 10) {
                                        Image(systemName: "minus.circle")
                                            .onTapGesture {
                                                commande.decrease(s)
                                            }
                                        
                                        //quantity
                                        Text("\(s.quantity)")
                                        Image(systemName: "plus.circle")
                                            .onTapGesture {
                                                commande.increase(s)
                                            }
                                    }
                                }
                                Spacer()
                                //Cost
                                Text("\((s.price).formatted(.currency(code: "EUR")))").font(.title3).bold()
                            }
                            //Swipe action
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    commande.remove(s)
                                } label: {
                                    VStack{
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                            .tint(.red)
                                    }
                                    .frame(width: 50)
                                    .background(.red)
                                }
                                .frame(width: 50)
                            }
                        }
                    }
                    //promocode
                    //PromoCode
                    Section {
                        
                    }
                header: {
                    HStack{
                        TextField("Coupon", text: .init(get: {
                            coupon.this.code
                        }, set: { Value in
                            coupon.this.code = Value
                        }))
                            .textCase(.uppercase)
                            .autocapitalization(UIKit.UITextAutocapitalizationType.allCharacters)
                            .padding()
                            .background(Color("xpress").opacity(0.3).gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                            
                        
                        Button{
                            Task{
                                commande.this.discount = await coupon.this.Check_Coupon()
                            }
                        }label: {
                            Text("Appliquer")
                                .font(.caption)
                                .padding(7)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("xpress").gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                    .padding(.vertical)
                    .shadow(radius: 1)
                    
                }
                footer: {
                    //If promocode is correct
                    HStack{
                        if (coupon.this.discount != Decimal()){
                            
                            Label(coupon.this.discount.formatted(.currency(code:"eur")), systemImage: "checkmark.circle")
                                .foregroundColor(.green)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                    }
                    .background(Color.clear)
                    //padding to escape the bottom bar
                    .padding(.bottom, 300)
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .listStyle(.insetGrouped)
                .listRowSeparator(.visible, edges: VerticalEdge.Set.bottom)
                .background(Color.clear)
                .frame(maxWidth: .infinity)
                
            }
           // .blur(radius: userdata.cart.isEmpty ? 20 : 0)
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
                            Text(commande.this.delivery.formatted(.currency(code: "EUR")))
                                .bold()
                        }
                        .padding(.horizontal)
                        
                        //reduction
                        HStack(alignment: .center) {
                            Text("Reduction")
                            Spacer()
                            Text(coupon.this.discount.formatted(.currency(code: "EUR")))
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
                    .padding(.bottom, 80)
                }
                
            }
            .padding()
            .background(Color("xpress").opacity(0.5).gradient)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.bottom)
            
            //get delivery cost
            .onAppear {
                Task{
                    let _ = await commande.setDeliveryCost(utilisateur.this)
                }
                
            }
            //.blur(radius: userdata.cart.isEmpty ? 20 : 0)
            
            //if cart is empty, print it
            
            if commande.isEmpty{
                VStack(alignment: .center, spacing: 20) {
                    Image("empty")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 200)
                        .background(.bar)
                        .shadow(radius: 5)
                        .clipShape(Circle())
                    Text("Panier Vide")
                        .font(.custom("coffeeandcrafts", size: 50))
                        
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background(Color("xpress"))
                .background(Material.ultraThinMaterial)
            }
             
        }
        .frame(alignment: .bottom)
        
        //Dates pages
        .fullScreenCover(isPresented: $userdata.show_date_selector_view) {
            Date_selector_View(show: $userdata.show_date_selector_view)
        }
        
        //Confirmation page
        .sheet(isPresented: $commande.confirmed, onDismiss: {
            //on dismiss
            //Command.current_cart = [:]
            //Command.current_cart.removeAll()
            //userdata.currentCommand = Command()
            commande.erase()
            commande.confirmed = false
            
        }, content: {
            Command_confirmation()
        })
        //Background
        .background(.ultraThinMaterial)
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
