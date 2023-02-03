//
//  HomeView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/02/2022.
//

import SwiftUI
import Foundation

var showSewingA:Bool = false
var sewingCost:Int = 0

struct HomeView: View {
    @EnvironmentObject var userdata:UserData
    @Namespace var animation:Namespace.ID
    @Namespace var namespace
    @State var selectedCategory:String = String()
    @State private var date = Date()
    @State private var showSheet = false
    @State var showSewing:Bool = false
    @State var showWash:Bool = false
    @State var showShoes:Bool = false
    @State var showPage:Bool = false
    @EnvironmentObject var fetchModel : FetchModels
    @State var gridLayout: [GridItem] = [ GridItem(.flexible()),GridItem(.flexible())]
    @State var rows = [GridItem(.adaptive(minimum: 200)), GridItem(.adaptive(minimum: 150))]
    @State var dicoInfo:[String:String] = [:]
    @State var S:CGSize = CGSize.init()
    @State var service:[Service] = [Service.init()]
    @State var currentArticle : Service = Service.init()
    var body: some View {
        GeometryReader {
            proxy in
            let Size = proxy.size
            let frameY = proxy.frame(in: .named("SCROLL")).minY  // Valeur de scroll sur Y
            let minY = proxy.frame(in: .named("SCROLL")).minY + proxy.safeAreaInsets.top
            VStack{
                ScrollView(showsIndicators: false) {
                    VStack{
                        //Date
                        VStack{
                            Greetings(proxy: Size)
                        }
                        Categories()
                            .offset(y:-frameY)
                            .opacity(minY)
                            .padding(.top, 200)
                        //Liste des services associés
                        VStack{
                            ServicesList()
                        }.padding(.top, 100)
                            .zIndex(3)
                    }
                    .overlay(alignment: .top) {
                        HeaderView(proxyScroll:Size)
                    }
                }
                .coordinateSpace(name: "SCROLL")
                .onAppear{
                    withAnimation(.interactiveSpring()){
                        userdata.taskbar = true
                    }
                    
                }
            }
            
            if showPage{
                withAnimation(.interactiveSpring(blendDuration: 0.4)) {
                    ArticleView(_article: currentArticle, show_page: $showPage)
                        .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.spring())))
                        .transaction { t in
                            t.isContinuous = true
                            t.animation = .spring()
                                
                        }
                        .matchedGeometryEffect(id: "service", in: namespace)
                        //.matchedGeometryEffect(id: "service", in: selectedCategory)
                }
            }
        }
        .background{
            VStack{
                Circle().scale(0.5).fill(.white.opacity(0.5))
                    .blur(radius: 30, opaque: false)
                    .shadow(color: .blue, radius: 90)
                    .offset(x:-80,y:-300)
            }
            .frame(maxWidth: 450, maxHeight: .infinity)
            .background(Color("fond"))
        }
        .onAppear {
            Task{
               await fetchModel.FetchServices()
                print(userdata.currentUser)
            }
            
            dicoInfo = fetchModel.GetServiceMessage()
            
        }
    }
    
    @ViewBuilder
    func HeaderView(proxyScroll:CGSize)->some View{
        GeometryReader {
            let minY = $0.frame(in: .named("SCROLL")).minY
            VStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:20){
                        //Toutes catégories
                        VStack{
                            if (selectedCategory == ""){
                                
                            }
                            Label("Populaires", systemImage: "flame.fill")
                                .font(Font.custom("Ubuntu", size: 25).bold())
                                .opacity(selectedCategory == "" ? 1 : 0.8)
                                .foregroundColor(selectedCategory.isEmpty ? Color.orange : Color.primary)
                        }.onTapGesture {
                            withAnimation(.easeInOut){
                                selectedCategory = String()
                            }
                            
                        }
                        //Catégories
                        ForEach(fetchModel.GetCategories().sorted(by: <), id: \.self) { cat in
                            VStack{
                                if (selectedCategory == cat){
                                    Rectangle().frame(height: 5)
                                }
                                Text("\(cat)")
                                    .font(Font.custom("Ubuntu", size: 25).bold())
                                    .opacity(selectedCategory == cat ? 1 : 0.8)
                            }
                            .padding(5)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.linear){
                                    selectedCategory = cat
                                }
                            }
                            
                        }
                    }
                    
                    
                    
                }
                .padding()
            }.frame(height: 120, alignment:.bottom)
                .background(.ultraThinMaterial)
                .onChange(of: minY, perform: { newValue in
                    Task{
                        print(minY)
                    }
                })
                .opacity(minY <= -250 ? 1 : 0)
                .offset(y:-minY)
                .frame(height: $0.safeAreaInsets.top)
        }
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func ServicesList() -> some View {
        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 20, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(fetchModel.services.sorted(by: {$0.id < $1.id}), id: \.self) {
                    card in
                    if (card.categories.contains(selectedCategory) || selectedCategory.isEmpty){
                        ZStack(alignment:.bottom){
                            Image(uiImage: (fetchModel.services_Images[card.illustration] ?? UIImage(named: "logo120"))!)
                                .resizable()
                                .clipped()
                                .scaledToFill()
                                .frame(maxWidth: 150)
                                //.offset(x:0, y:-10)
                                //.matchedGeometryEffect(id: "service", in: namespace)
                            VStack(alignment: .center, spacing: 5) {
                                VStack{
                                    Text("\(card.name)")
                                        .font(.custom("Ubuntu", size: 20))
                                        .padding(.horizontal)
                                        Text("\(card.cost.formatted(.currency(code: "EUR")))")
                                        .padding(.horizontal)
                                }
                                .padding(.horizontal,2)
                                .padding(.vertical, 5)
                                .background(Material.bar)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .offset(y:-20)
                            }
                            .frame(maxWidth: .infinity, alignment:.center)
                            
                            
                        }
                        
                        //.shadow(radius: 5)
                        .frame(height: 250)
                        .background(Material.ultraThin)
                        .clipShape(RoundedRectangle(cornerRadius: 20), style: .init(eoFill: true))
                        .padding(.bottom,10)
                        .onTapGesture {
                            Task{
                                currentArticle = card
                                withAnimation(.spring()){
                                    showPage = true
                                }
                            }
                        }
                    }
                   
                    
                }
            }
            .padding(.horizontal, 5)
        }
        //.padding(.horizontal, 10)
        //.onAppear(perform: fetchModel.fetchSewing)
        .onAppear{
            print("voici les images")
            print(fetchModel.services_Images)
        }
    }
    
    @ViewBuilder
    func Categories() -> some View {
        
        //let minY = Proxy.frame(in: .named("SCROLL")).minY
        //var progress = minY / (proxyScroll.height * 400)
        GeometryReader { GeometryProxy in
            VStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:20){
                        //Toutes catégories
                        VStack{
                            if (selectedCategory == ""){
                                
                            }
                            Label("Populaires", systemImage: "flame.fill")
                                .font(Font.custom("Ubuntu", size: 25).bold())
                                .opacity(selectedCategory == "" ? 1 : 0.8)
                                .foregroundColor(selectedCategory.isEmpty ? Color.orange : Color.primary)
                        }.onTapGesture {
                            withAnimation(.easeInOut){
                                selectedCategory = ""
                            }
                            
                        }
                        //Catégories
                        ForEach(fetchModel.GetCategories().sorted(by: <), id: \.self) { cat in
                            VStack{
                                Text("\(cat)")
                                    .font(.title2)
                                    .bold(true)
                                    .foregroundColor(selectedCategory == cat ? Color.primary : .secondary)
                                    .opacity(selectedCategory == cat ? 1 : 0.8)
                            }
                            .padding(5)
                            .background{
                                if (selectedCategory == cat){
                                    Capsule().fill(Color("xpress"))
                                        .matchedGeometryEffect(id: "selectedcategory", in: animation)
                                }
                            }
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.linear){
                                    selectedCategory = cat
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
            }
            .frame(height: 150, alignment:.bottom)
            
        }
        //.offset(y: minY < 100 ? -minY : 0).animation(.easeInOut, value: minY)
        .zIndex(10)
        
    }
    
    @ViewBuilder
    func Greetings(proxy:CGSize) -> some View{
        GeometryReader { GeometryProxy in
            let minY = GeometryProxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (proxy.height * 0.6)
            VStack{
                Image("page 1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.width, height: proxy.height + (minY > 0 ? minY : 0))
                    .clipped()
                    .overlay(content: {
                        ZStack (alignment: .top, content: {
                            Rectangle().fill(.linearGradient(colors: [Color("fond").opacity(0 - progress),
                                                                      Color("fond").opacity(0.6 - progress),                       Color("fond").opacity(1 - progress),
                                             
                                                                      
                                                                      Color("fond").opacity(1),]
                                                             , startPoint: .top, endPoint: .bottom))
                            HStack (spacing: 0, content: {
                                Text("Bonjour \(userdata.currentUser.name),")
                                    .font(Font.custom("Ubuntu", size: 30,relativeTo: .title))
                            })
                            .padding(.top, 210)
                            .opacity(minY == 0 ? 1 : (1 + progress))
                            .offset(x: -minY)
                            
                        })
                    })
                    .offset(y : -minY) // L'image reste figée
            }.frame(height: GeometryProxy.size.height * 40 + GeometryProxy.safeAreaInsets.top)
        }
    }
    
    
    @State var quantity : Int = 0

    //Fonction qui calcule le tarif total
    func TotalCost () -> Decimal{
        var total:Decimal = 0
        userdata.currentServiceHasCommand.forEach { index in
            total += fetchModel.GetNameByID(sewingid: Int(index.service_ID_SERVICE)).cost * Decimal(index.quantity)
        }
        return total
    }
    
    @ViewBuilder
    func Announcement(proxyScroll:CGSize) -> some View {
        //let minY = proxyScroll.frame(in: .named("SCROLL")).minY
        
        GeometryReader() { Proxy in
            //var progress = proxyScroll.height / (proxyScroll.height * 0.6)
            let minY = Proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (proxyScroll.height * 0.6)
            VStack(alignment:.center){
                Image("annonce")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(50)
                    .frame(width: proxyScroll.width, height: proxyScroll.height + (minY > 0 ? minY : 0))
                
                //.clipped()
                    .opacity(1 - progress)
                    .overlay(content: {
                        ZStack (alignment: .bottom, content: {
                            Rectangle().fill(.linearGradient(colors: [.black.opacity(0 - progress),
                                                                      .black.opacity(0.1 - progress),
                                                                      .black.opacity(0.3 - progress),
                                                                      .black.opacity(0.5 - progress),
                                                                      .black.opacity(0.7 - progress),
                                                                      .black.opacity(1),]
                                                             , startPoint: .top, endPoint: .bottom))
                            VStack (spacing: 0, content: {
                                Text("Annonces")
                                    .font(Font.custom("Ubuntu", size: 50,relativeTo: .title))
                                    .colorInvert()
                                    .shadow(radius: 10)
                            })
                            .opacity(minY == 0 ? 1 : (1 + progress))
                            .offset(y: -minY)
                            
                        })
                    })
                    .offset(y : -minY) // L'image reste figée
            }.frame(height: Proxy.size.height/2)
            
            
        }
        .ignoresSafeArea(.all)
        //.edgesIgnoringSafeArea(.horizontal)
        .zIndex(2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}




