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
    @Environment(\.colorScheme) var colorscheme
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
            
            //Article image in background wiht overlay
            ZStack(alignment:.trailing){
                Image(uiImage: (article.images[article.this.illustration] ?? UIImage(named: "page 4"))!)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(maxWidth: size.width, maxHeight: .infinity)
                VStack{
                    
                }
                .frame(maxWidth: size.width, maxHeight: .infinity)
                .background(LinearGradient(colors: [
                colorscheme == .dark ? .black.opacity(0) : .white.opacity(0),
                colorscheme == .dark ? .black.opacity(1) : .white.opacity(1)
                ], startPoint: .top, endPoint:.bottom))
                
                //MARK: Quantity selector
                VStack{
                    Text("Quantité")
                        .bold()
                        .shadow(radius: 2)
                    Picker("Quantité", selection: $achat.quantity) {
                        withAnimation() {
                            ForEach(0...100,id: \.self) {
                                Text(" \($0)").tag($0)
                                    //.font(achat.quantity == $0 ? .largeTitle : .callout)
                                    //.foregroundStyle(achat.quantity == $0 ? .blue : .white)
                            }
                        }
                       
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    .labelStyle(.titleAndIcon)
                    .padding(1)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
                
                .animation(.spring(), value: quantity)
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: size.width)
            
            // Description and others
            VStack(alignment:.leading){
                // Process time
                Label("\(article.this.time) jours pour la livraison", systemImage: "info.circle")
                    .font(Font.custom("Ubuntu", size: 10.0))
                    .shadow(color: Color("fond"), radius: 10)
                    .tint(.gray)
                    .underline()

                
                // Article Name
                HStack(alignment: .top) {
                    Text("\(article.this.name)")
                        .font(Font.custom("BebasNeue", size: 50.0))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.2)
                        .shadow(radius: 3)
                }
                //Description
                HStack{
                    Text(article.this.description)
                    //.background(.thinMaterial)
                    //.clipShape(RoundedRectangle(cornerRadius: 10))
                    .font(Font.custom("Ubuntu", size: 13.0))
                    //.multilineTextAlignment(.leading)
                    
                }
                .frame(maxWidth: .infinity, alignment:.leading)
                
                //caution
                if article.this.description.contains("kilo"){
                    GroupBox(content: {
                        Text("Nos experts se chargeront d'estimer le poids exact")
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            
                    }, label: {
                        Label("Info", systemImage: "info.circle")
                    })
                    .background(.thinMaterial)
                    .padding(.horizontal)
                    .font(.caption)
                }
                //MARK: Price
                VStack(alignment: .leading, spacing: 0) {
                    var total = Decimal(achat.quantity) * article.this.cost
                    Text("\((article.this.cost).formatted(.currency(code: "EUR")))").font(.custom("BebasNeue", size: 30)).bold()
                        //.shadow(color: colorscheme == .dark ? .white : .black, radius: 10)
                        .shadow(radius: 5)
                    //MARK: Total Price
                    HStack{
                        Text("x\(achat.quantity) unités")
                            .font(.caption2)
                        Text("\(total.formatted(.currency(code: "eur")))")
                            .font(.custom("BebasNeue", size: 20))
                            .opacity(achat.quantity > 0 ? 1 : 0)
                    }
                    
                }
                
                //MARK: To buy button
                    HStack(alignment:.center){
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
                        .background(Color("xpress"))
                        .cornerRadius(10)
                        .foregroundColor(Color.primary)
                        .padding()
                    }
                    .minimumScaleFactor(0.4)
                    .scaleEffect(achat.quantity > 0 ? 1:0,anchor: UnitPoint.center)
                    .animation(.spring(), value: achat.quantity)
                
            }
            .frame(maxWidth: size.width, maxHeight: size.height, alignment:.bottom)
            .padding(.vertical, 50)
            .animation(.spring(), value: quantity)
            
            // Return and cart buttons
            HStack(alignment: .center, content: {
                //back button
                Image(systemName: "chevron.backward")
                    .foregroundStyle(colorscheme == .dark ? .white : .black)
                    .shadow(radius: 2)
                    .padding()
                    .background(.bar)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        show_page.toggle()
                    }
                Spacer()
                
            })
            .padding(.horizontal, 20)
            .frame(width: size.width, height: 50, alignment: .bottom)
            .padding(.top, 70)
            
        }
        //.background(Color("xpress").opacity(0.2).gradient)
        .background(.bar)
        .ignoresSafeArea()
        .onAppear{
            achat.service = article.this
            achat.quantity = 0
            if commande.services.contains(where: {$0.service == article.this}){
                achat.quantity = commande.getQuantityOf(article.this)
            }
            
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
