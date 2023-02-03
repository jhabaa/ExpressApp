//
//  ServicePage.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 09/04/2022.
//

import SwiftUI

struct PurchasedItem : Hashable{
    var id: Int64
    var purchased: Bool
}

struct ServicePage: View {
    @EnvironmentObject var fetchModels:FetchModels
    @Binding var showPage:Bool
    @State var test:[Bool] = []
    @Namespace var namespace : Namespace.ID
    @EnvironmentObject var userdata:UserData
    @State private var purchased:[PurchasedItem] = [PurchasedItem.init(id: 0, purchased: false)]
    @State var paidList:[String:Bool] = [:]
    @State private var clickOnArticle:[Bool] = []
    @State var illustrationPict:String
    @State var service:[Service]
    @State var gridLayout: [GridItem] = [ GridItem(.flexible()),GridItem(.flexible())]
    @State var clickedItem:Int = 0
    @State var updatePrive:Bool = false
    @State var commandNewId:Int64 = 0
    var body: some View {
        GeometryReader  { proxy in
            ScrollView{
                
                // Image En-tête
                    VStack(alignment: .center, spacing: 10) {
                        AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(illustrationPict)") , content: { image in
                            image.resizable().scaledToFit()
                        }, placeholder: {
                            ProgressView()
                        })
                        Text("Informations sur le service").font(.caption)
                    }.frame(width: 200, height: 300, alignment: SwiftUI.Alignment.center)
                
                    .matchedGeometryEffect(id: illustrationPict, in: namespace)
                
                    //Objects
                    
                        LazyVGrid(columns: gridLayout, alignment: HorizontalAlignment.center, spacing: 20, pinnedViews: .sectionHeaders) {
                            Section {
                                ForEach(service, id: \.self) {item in
                                    //Remplissage tu tableau à faire
                                    ZStack{
                                        
                                            
                                    }.frame(width: proxy.size.width/2, height: proxy.size.height/4)
                                        .background(Material.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                                        .overlay(content: {
                                            AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(item.name)") , content: { image in
                                                image.resizable().scaledToFit().offset(x: 0, y: -20).zIndex(1)
                                            }, placeholder: {
                                                ProgressView()
                                            })
                                                .shadow(color: Color.blue, radius: 10, x: 5, y: 5)
                                                .scaleEffect(paidList[item.name] == true ? 1.2 : 1)
                                                .offset(x: 0, y: -30)
                                                .overlay(alignment: SwiftUI.Alignment.bottom) {
                                                    VStack{
                                                        Text("\(item.name)").padding().background(Material.ultraThinMaterial).cornerRadius(10).scaledToFit()
                                                        Text("\(item.cost.formatted(.currency(code: "EUR")))")
                                                            .bold()
                                                            .foregroundColor(.white)
                                                            .padding()
                                                            .transition(.scale)
                                                            .scaledToFit()
                                                            .background(.blue)
                                                            .onChange(of: item.cost) { V in
                                                                
                                                            }
                                                    }.scaledToFit()
                                                        .zIndex(200)
                                                }
                                                
                                        }
                                        )
                                    
                                    .rotation3DEffect(.degrees(paidList[item.name] == true ? 0 : 360), axis: (x: 0, y: 1, z: 0))
                                    .onAppear(perform: {
                                        //add to dictionnary
                                        paidList.updateValue(false, forKey: item.name)
                                    })
                                    
                                    .padding([.trailing,.leading,.top])
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            changePurchasedState(id:Int64(item.id), table: &purchased)
                                            //add to dictionnary
                                            paidList[item.name]?.toggle()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                withAnimation(.spring()) {
                                                    paidList[item.name]?.toggle()
                                                }
                                               
                                            }
                                            
                                        }
                                        //Code exécuté quand on clique sur un article
                                        //il s'ajoute à ServiceHasCommand
                                        userdata.AddToServiceHasCommand(id: item.id)
                                        //On ajoute le tarif à la commande
                                        print(userdata.currentServiceHasCommand)
                                    }
                                    .animation(Animation.spring(), value: purchased)
                                }
                            }header: {
                                VStack{
                                    HStack{
                                        Button(action: {}, label: {
                                            HStack{
                                                Text("To Pay")
                                                Divider()
                                                Spacer()
                                                Text("\(TotalCost().formatted(.currency(code: "EUR")))").bold().font(.title2).rotationEffect(.degrees(updatePrive ? 10 : 0))
                                                    .scaleEffect(updatePrive ? 1.3 : 1)
                                                    .zIndex(100)
                                                                                                                                             
                                            }
                                        }).clipShape(Rectangle())
                                    }
                                    .onChange(of: TotalCost(), perform: { V in
                                        withAnimation(.spring()) {
                                            
                                           
                                            updatePrive.toggle()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                withAnimation(.spring()) {
                                                    updatePrive.toggle()
                                                }
                                               
                                            }
                                            
                                        }
                                    })
                                    
                                    .matchedGeometryEffect(id: "barSewing", in: namespace)
                                    
                                }
                                .padding(20)
                                .background(updatePrive ? .thickMaterial : .ultraThinMaterial)
                                .cornerRadius(20)
                                .overlay {
                                    Text("esssai").foregroundColor(.green)
                                }
                                .padding()
                            }
                            .offset(x: 0, y: -30)
                            

                        }
                        .onAppear{
                            Task{
                                await fetchModels.FetchServices()
                            }
                            
                        }
                        
                        .transition(.scale)

                
            }
            .overlay {
                VStack{
                    HStack{
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showPage.toggle()
                            }
                        }, label: {
                            Image(systemName: "xmark.circle.fill").font(.largeTitle).shadow(color: .white, radius: 4).colorMultiply(.gray)
                        })
                            .padding()
                        
                        
                    }
                    Spacer()
                }.padding().zIndex(4)
            }
        }.edgesIgnoringSafeArea(.top)
            .onSubmit {
            fetchModels.getServices(category: "sewing")
        }   
    }
    
    //Fonction qui calcule le tarif total
    func TotalCost () -> Decimal{
        var total:Decimal = 0
        userdata.currentServiceHasCommand.forEach { index in
            total += fetchModels.GetNameByID(sewingid: Int(index.service_ID_SERVICE)).cost * Decimal(index.quantity)
        }
        return total
    }

}

//Fonction qui prend un ID, vérifie dans un tableau et renvoie sa valeur booléenne
func getPurchasedState(id:Int64, table:[PurchasedItem]) -> Bool{
    var state:Bool = false
    table.forEach { purchasedItem in
        if purchasedItem.id == id{
            state = purchasedItem.purchased
        }
    }
    return state
}

//Fonction qui toggle une valeur booleenne dans un tableau à partir de l'ID
func changePurchasedState(id:Int64, table : inout[PurchasedItem]){
    table.forEach {
        var value = $0
        if $0.id == id{
            value.purchased.toggle()
        }
    }
}

//Fonction qui ajoute un element au dictionnaire en prennant un ID et la valeur par defaut false
func AddToPurchasedTable(id:Int64, table:inout [PurchasedItem]){
    table.append(PurchasedItem(id: id, purchased: false))
}



struct Previews_ServicePage_Previews: PreviewProvider {
    static var previews: some View {
        ServicePage(showPage: Binding.constant(true), illustrationPict: "jean", service: [Service()])
    }
}
