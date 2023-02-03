//
//  ArticleView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 16/04/2023.
//

import SwiftUI

struct ArticleView: View {
    @EnvironmentObject var userdata : UserData
    @EnvironmentObject var fetchmodel:FetchModels
    //@Namespace var animation : Namespace.ID
    @Namespace var selected_service:Namespace.ID
    @State var _article:Service
    @State var quantity = 0
    @Binding var show_page:Bool
    @State var choice_method:Bool = true
    var body: some View {
        GeometryReader{ GeometryProxy in
            let size = GeometryProxy.size
            VStack{
                Image(uiImage: (fetchmodel.services_Images[_article.illustration] ?? UIImage(named: "logo120"))!)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .frame(height: size.height/2)
                    .scaledToFill()
                    .padding()
                
                // Article Name
                HStack(alignment: .top) {
                    Text("\(_article.name)")
                        .font(Font.custom("Ubuntu", size: 30.0))
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                    VStack{
                        Text("\((_article.cost).formatted(.currency(code: "EUR")))").font(.custom("GashingtonClassy", size: 50)).bold()
                            //.shadow(color: Color("fond"), radius: 10)
                        Label("\(_article.time) jours pour livraison", systemImage: "info.circle")
                            .font(Font.custom("Ubuntu", size: 10.0))
                            .shadow(color: Color("fond"), radius: 10)
                            .foregroundColor(.gray)
                            .tint(.gray)
                    }
                    
                    
                }
                .padding(.horizontal)
                //Description
                
                Text(_article.description)
                .frame(maxWidth: .infinity)
                //.background(.thinMaterial)
                //.clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                //caution
                if _article.name.contains("kilo"){
                    GroupBox(content: {
                        Text("Nos experts se chargeront d'estimer le poids exact")
                            
                    }, label: {
                        Label("Info", systemImage: "info.circle")
                    })
                    .background(.thinMaterial)
                    .padding(.horizontal)
                    .font(.caption)
                }
                
                //Quantity & selector
                HStack{
                    LazyVGrid(columns: [GridItem(.flexible(minimum: 200, maximum: 300)), GridItem(.flexible(minimum: 150, maximum: 300))]) {
                        //Quantity
                        if Command.current_cart.contains(where: {$0.key == _article}){
                            VStack{
                                Text("\(Command.current_cart[_article]!)")
                                    .padding()
                                    .font(.custom("Coffee and crafts", size: 50)).bold()
                                    
                            }
                            .frame(maxWidth: .infinity)
                            .background(.thinMaterial)
                            .cornerRadius(20)
                        }else{
                            VStack{
                                Text("\(quantity > 0 ? String(quantity) : " ")")
                                    .padding()
                                    .font(.custom("Coffee and crafts", size: 50)).bold()
                            }
                            .frame(maxWidth: .infinity)
                            .background(.thinMaterial)
                            .cornerRadius(20)
                        }
          
                            
                        
                        //buttons
                        HStack{
                            LazyVGrid(columns: [GridItem(),GridItem()]) {
                                VStack{
                                    Text("-")
                                        .font(.custom("", size: 50))
                                        .frame(height: 80)
                                        .clipped()
                                }
                                .frame(maxWidth: .infinity, maxHeight:.infinity)
                                .background(.thickMaterial)
                                .onTapGesture {
                                    //quantity -= quantity > 0 ? 1 : 0
                                    //userdata.RemoveServiceFromCart(s: _article)
                                    quantity -= quantity > 0 ? 1 : 0
                                }
                                
                                VStack{
                                    Text("+")
                                        .font(.custom("", size: 40))
                                        .bold()
                                        
                                        
                                }
                                .frame(maxWidth: .infinity, maxHeight:.infinity)
                                .background(.thickMaterial)
                                .onTapGesture {
                                    //userdata.AddServiceToCart(s: _article)
                                    quantity += 1
                                }
                            }
                        }
                        //.frame(maxWidth: .infinity, maxHeight:.infinity)
                        .background(.thinMaterial)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    
                    
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.top)
            
            // Add to cart button
            if quantity > 0{
                VStack(alignment:.center){
                    
                    Button {
                        //add to cart
                        Command.current_cart.updateValue(quantity, forKey: _article)
                    } label: {
                        Label("Ajouter au panier", systemImage: "shippingbox.circle.fill")
                            .font(.title)
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color("fond"))
                    .cornerRadius(30)
                    .foregroundColor(Color.primary)
                    .padding()

                }
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment:.bottom)
                .animation(.spring(), value: quantity)
            }
            
        }
        
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 5).background{
                Image(systemName: "arrow.backward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
            .clipped()
            .frame(width: 50, height:50)
            .onTapGesture {
                //userdata.Back()
                show_page = false
            }
            .padding(.top,50)
            .padding(.leading, 30)
        }
        .overlay(alignment: .topTrailing) {
            if !userdata.cart.isEmpty{
                RoundedRectangle(cornerRadius: 5).background{
                    Image(systemName: "cart.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                }
                .clipped()
                .frame(width: 50, height:50)
                .onTapGesture {
                    //userdata.Back()
                    show_page = false
                }
                .padding(.top,50)
                .padding(.trailing, 30)
            }
            
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .onAppear{
            quantity = 0
            Task{
                await userdata.SetDeliveryCost()
            }
            withAnimation(.spring()){
                userdata.taskbar = false
            }
        }
        .onDisappear{
            withAnimation(.spring()){
                userdata.taskbar = true
            }
        }
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(_article: Service(), show_page: Binding.constant(true)).environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}
