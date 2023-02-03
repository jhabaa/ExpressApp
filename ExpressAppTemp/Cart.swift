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
    @State var promoCode:String=String()
    @State var coupon_value:String=String()
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
                        ForEach(Command.current_cart.keys.sorted(by: {$0.time < $1.time}), id: \.self) {
                            service in
                            // Entry of the cart
                            HStack(alignment:.bottom){
                                // Image of the service
                                Image(uiImage: (fetchmodel.services_Images[service.name] ?? UIImage(named: "logo120"))!)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                                
                                //Name of the servive and quantity up and downdable
                                VStack(alignment: .leading, spacing: 20) {
                                    Text(service.name)
                                        .bold()
                                    
                                    //quantity and buttons
                                    HStack(alignment: .bottom, spacing: 10) {
                                        Image(systemName: "minus.circle")
                                            .onTapGesture {
                                                userdata.currentCommand.decrease_in_cart(service)
                                                update_value.toggle()
                                                update_value.toggle()
                                            }
                                        
                                        //quantity
                                        if update_value{
                                            Text("\(Command.current_cart[service]!)")
                                        }
                                        
                                        
                                        Image(systemName: "plus.circle")
                                            .onTapGesture {
                                                userdata.currentCommand.increase_in_cart(service)
                                                update_value.toggle()
                                                update_value.toggle()
                                            }
                                        
                                    }
                                }
                                Spacer()
                                //Cost
                                Text("\((service.cost * Decimal(Command.current_cart[service]!)).formatted(.currency(code: "EUR")))").font(.title3).bold()
                            }
                            //Swipe action
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    
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
                        TextField("Coupon", text: $promoCode)
                            .textCase(.uppercase)
                            .autocapitalization(UIKit.UITextAutocapitalizationType.allCharacters)
                            .padding(.horizontal)
                        

                        Button{
                            Task{
                                coupon_value = await userdata.Check_Coupon(Coupon(promoCode, Decimal(0.00)))
                            }
                        }label: {
                            Text("Appliquer")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.primary)
                    }
                    .padding(.vertical)
                    .background(.thickMaterial)
                    .shadow(radius: 1)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                }
                footer: {
                    //If promocode is correct
                    HStack{
                        if !coupon_value.isEmpty{
                            Label("\(coupon_value)", systemImage: "checkmark.circle")
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
                            Text(userdata.currentCommand.get_sub_total.formatted(.currency(code: "EUR")))
                               .bold()
                        }
                        .padding(.horizontal)
                        
                        //Shipping cost
                        HStack(alignment: .center) {
                            Text("Frais livraison")
                            Spacer()
                            Text(userdata.currentCommand.delivery.formatted(.currency(code: "EUR")))
                                .bold()
                        }
                        .padding(.horizontal)
                        
                        //reduction
                        HStack(alignment: .center) {
                            Text("Reduction")
                            Spacer()
                            Text(userdata.currentCommand.discount.formatted(.currency(code: "EUR")))
                                .bold()
                        }
                        .padding(.horizontal)
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                    HStack(alignment: .center) {
                        Text("Total")
                        Spacer()
                        Text(userdata.Get_Cost_command().formatted(.currency(code: "EUR")))
                            .bold()
                    }
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
                .background(.ultraThinMaterial)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.bottom)
            //.blur(radius: userdata.cart.isEmpty ? 20 : 0)
            
            //if cart is empty, print it
            
            if Command.current_cart.isEmpty{
                VStack(alignment: .center, spacing: 20) {
                    Text("Panier Vide")
                        .font(.custom("coffeeandcrafts", size: 50))
                        
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background(Material.ultraThinMaterial)
            }
             
        }
        .frame(alignment: .bottom)
        
        //Dates pages
        .fullScreenCover(isPresented: $userdata.show_date_selector_view) {
            Date_selector_View(show: $userdata.show_date_selector_view, command_id: $command_id_after_check)
        }
        
        //Confirmation page
        .sheet(isPresented: $userdata.command_confirmation, onDismiss: {
            //on dismiss
            Command.current_cart = [:]
            Command.current_cart.removeAll()
            userdata.currentCommand = Command()
        }, content: {
            Command_confirmation(_command_id: $command_id_after_check)
        })
        //Background
        .background(.ultraThinMaterial)
    }
    
}

struct Cart_Previews: PreviewProvider {
    static var previews: some View {
        Cart().environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}
