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
    @EnvironmentObject var commande:Commande
   // @EnvironmentObject var panier:Panier
    @EnvironmentObject var article:Article
    @EnvironmentObject var alerte:Alerte
    //@Namespace var animation : Namespace.ID
    @Namespace var selected_service:Namespace.ID
    //@State var _article:Service
    @State var quantity = 0
    @Binding var show_page:Bool
    @State var choice_method:Bool = true
    @State var achat:Achat = Achat(quantity: 0)
    var body: some View {
        GeometryReader{ GeometryProxy in
            let size = GeometryProxy.size
            VStack{
                ZStack(alignment: .bottomTrailing, content: {
                    Image(uiImage: (article.images[article.this.illustration] ?? UIImage(named: "logo120"))!)
                        .resizable()
                        .clipped()
                    Text("\((article.this.cost).formatted(.currency(code: "EUR")))").font(.custom("GashingtonClassy", size: 50)).bold()
                        .padding(10)
                        .background(.bar)
                        
                })
                
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal)
                    .frame(width:size.width,height: size.height/2)
                
                // Process time
                Label("\(article.this.time) jours pour livraison", systemImage: "info.circle")
                    .font(Font.custom("Ubuntu", size: 10.0))
                    .shadow(color: Color("fond"), radius: 10)
                    .foregroundColor(.gray)
                    .tint(.gray)

                
                // Article Name
                HStack(alignment: .top) {
                    Text("\(article.this.name)")
                        .font(Font.custom("Ubuntu", size: 30.0))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal)
                //Description
                
                Text(article.this.description)
                .frame(maxWidth: .infinity)
                //.background(.thinMaterial)
                //.clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                //caution
                if article.this.name.contains("kilo"){
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
                        if commande.services.contains(where: {$0.service == article.this}){
                            VStack{
                                Text("\(commande.getQuantityOf(article.this))")
                                    .padding()
                                    .font(.custom("Coffee and crafts", size: 50)).bold()
                                    
                            }
                            .frame(maxWidth: .infinity)
                            .background(.thinMaterial)
                            .cornerRadius(20)
                        }else{
                            VStack{
                                Text("\(quantity > 0 ? String(quantity) : "0")")
                                    .padding()
                                    .font(.custom("Ubuntu", size: 50)).bold()
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
                                    achat.quantity += 1
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
                HStack(alignment:.center){
                    VStack{
                        // Total mention
                        Text("Total")
                            .font(.caption2)
                        var total = Decimal(quantity) * article.this.cost
                        Text("\(commande.getCost.formatted(.currency(code: "eur")))")
                    }
                    Button {
                        commande.toCart(achat)
                        //Show notification
                        alerte.this.text = "Article ajouté"
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            alerte.this.text = String()
                        })
                        //close view
                        withAnimation {
                            show_page = false
                        }
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
                .padding()
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment:.bottom)
                .animation(.spring(), value: quantity)
            }
            
            // Return and cart buttons
            HStack(alignment: .center, content: {
                //back button
                Image(systemName: "chevron.backward.square.fill")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 40)
                    .foregroundStyle(Color("xpress").opacity(0.4).gradient, .bar)
                    .onTapGesture {
                        show_page.toggle()
                    }
                    .shadow(radius: 2)
                    
                Spacer()
                
                //cart shortcut
                Image(systemName: "bag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .foregroundStyle(Color("xpress").opacity(0.4).gradient, .bar)
                    .shadow(radius: 2)
                    .overlay(alignment: .bottom) {
                        Text("\(commande.getNumberOfArticles)")
                            .padding(2)
                            .frame(maxWidth: .infinity)
                            .background(Color("xpress"))
                            .clipShape(Capsule())
                            
                    }
            })
            .padding(.horizontal, 20)
            .frame(width: size.width, height: 50, alignment: .center)
            .padding(.top, 70)
            
        }
        .background(Color("xpress").opacity(0.2).gradient)
        .background(.bar)
        .ignoresSafeArea()
        .onAppear{
            achat.service = article.this
            quantity = 0
            Task{
                //await userdata.SetDeliveryCost()
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
        ArticleView(show_page: Binding.constant(true)).environmentObject(UserData())
            .environmentObject(FetchModels())
            //.environmentObject(Panier())
            .environmentObject(Article())
            .environmentObject(Commande())
            .environmentObject(Alerte())
    }
}
