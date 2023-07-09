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
    @EnvironmentObject var article:Article
    @EnvironmentObject var utilisateur:Utilisateur
    @Environment(\.colorScheme) var colorscheme
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
    @State var searchForService:String=String()
    @State var news:Bool = false
    @State var categories_services:[String:[Article]]=[:]
    var body: some View {
        GeometryReader {
            proxy in
            let Size = proxy.size
            let frameY = proxy.frame(in: .named("SCROLL")).minY  // Valeur de scroll sur Y
            let minY = proxy.frame(in: .named("SCROLL")).minY + proxy.safeAreaInsets.top
            VStack{
                ScrollView(showsIndicators: false) {
                    
                    if selectedCategory.isEmpty{
                        // PUB
                        ADS(Size)
                            .scaleEffect(searchForService.isEmpty ? 1 : 0)
                            .animation(.spring(), value: searchForService)
                        // Greetings(proxy: Size)
                        
                        
                    }
                    VStack{
                        
                        
                        /*
                         Categories()
                         .offset(y:-frameY)
                         .opacity(minY)
                         */
                        //.padding(.top, 200)
                        //Liste des services associés
                        VStack(alignment:.leading){
                            ServicesList()
                        }.padding(.top, 10)
                            .zIndex(3)
                            .frame(alignment: .leading)
                        Divider()
                            .padding(.bottom, 330)
                    }
                    .offset(y: searchForService.isEmpty ? 320 : 0)
                    .animation(.spring(), value: searchForService)
                }
                .ignoresSafeArea(.all)
                .coordinateSpace(name: "SCROLL")
                .onAppear{
                    withAnimation(.interactiveSpring()){
                        userdata.taskbar = true
                    }
                    
                }
            }
            HeaderView(proxyScroll:Size)
            
            
            //News & updates
            if news{
#warning("To implement")
                ScrollView {
                    Text("Pas de notifications")
                        .font(.title)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 400, alignment:.center)
                .background(.ultraThinMaterial)
                .overlay(alignment: .topLeading) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 30)
                        .padding()
                        .foregroundStyle(.red)
                        .onTapGesture {
                            withAnimation(.spring()){
                                news.toggle()
                            }
                        }
                }
                
            }
            
            
            
            if showPage{
                withAnimation(.interactiveSpring(blendDuration: 0.4)) {
                    ArticleView(show_page: $showPage)
                        .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.spring())))
                        .transaction { t in
                            t.isContinuous = true
                            t.animation = .spring()
                        }
                        .matchedGeometryEffect(id: "service", in: namespace)
                }
            }
            
            
        }
        .background()
        /*
         .background{
         VStack{
         Circle().scale(0.5).fill(.white.opacity(0.5))
         .blur(radius: 30, opaque: false)
         .shadow(color: .blue, radius: 90)
         .offset(x:-80,y:-300)
         }
         .frame(maxWidth: 450, maxHeight: .infinity)
         .background()
         }
         */
    }
    
    @ViewBuilder
    func ADS(_ proxyScroll:CGSize)->some View{
        GeometryReader { Proxy in
            let minY = Proxy.frame(in: .named("scroll")).minY
            var progress = minY / (proxyScroll.height * 0.6)
            ZStack(alignment:.top){
                
                /// backgroundImageSwitcher()
                AsyncImage(url: URL(string: "http://express.heanlab.com/getimage?name=pub")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(progress > 0 ? progress + 1 : 1)
                    
                } placeholder: {
                    ProgressView()
                }
            }
            
            .offset(y : -minY) // L'image reste figée
            .overlay(content: {
                let themColor:Color = colorscheme == .dark ? .black : .white
                ZStack (alignment: .center, content: {
                    Rectangle().fill(.linearGradient(colors: [themColor.opacity(0 - progress),
                                                              themColor.opacity(0.1 - progress),
                                                              themColor.opacity(0.2 - progress),
                                                              themColor.opacity(0.5 - progress),
                                                              themColor.opacity(0.7 - progress),
                                                              themColor.opacity(1),]
                                                     , startPoint: .top, endPoint: .bottom))
                    .opacity(minY == 0 ? 1 : (1 - progress))
                    .scaleEffect(progress > 0 ? progress + 1 : 1)
                    .offset(y: -minY)
                })
                .ignoresSafeArea(.all)
            })
            
        }
    }
    
    
    @ViewBuilder
    func HeaderView(proxyScroll:CGSize)->some View{
        GeometryReader {
            let minY = $0.frame(in: .named("SCROLL")).minY
            
            ZStack {
                
                //search bar
                HStack(spacing:0){
                    Image(systemName: "magnifyingglass")
                    
                    TextField(text: $searchForService, prompt: Text("Rechercher un service")) {}
                        .padding(15)
                }
                .font(.custom("ubuntu", size: 20))
                .foregroundStyle(.gray)
                .padding(.horizontal, 40)
                .background(.bar)
                .clipShape(Capsule())
                .frame(height: 80)
            }
            .padding()
            .offset(y:80)
            // .frame(height: 120, alignment:.bottom)
            
            //.background(Color("xpress").opacity(0.3).gradient)
            .onChange(of: minY, perform: { newValue in
                Task{
                    print(minY)
                }
            })
            //.clipShape(RoundedRectangle(cornerRadius: 40))
            //.opacity(minY <= -250 ? 1 : 0)
            .offset(y:-minY)
            .frame(height: $0.safeAreaInsets.top)
            //.ignoresSafeArea(.all, edges: .top)
            .padding(.vertical)
            
        }
        .ignoresSafeArea(.container)
        .edgesIgnoringSafeArea(.all)
    }
    @State var currentNumberInView:Int=2
    @ViewBuilder
    func ServicesList() -> some View {
        VStack{
            ForEach(article.categories_services.sorted(by: {$0.key < $1.key}), id: \.key){ serviceInCategory in
                ZStack(alignment: .top) {
                    Text(serviceInCategory.key)
                        .font(.custom("BebasNeue", size: 100))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .offset(y:-70)
                        .scaleEffect(searchForService.isEmpty ? 1 : 0)
                        .opacity(0.5)
                    
                    let numberOfItems:Int = serviceInCategory.value.count
                    Section {
                        if searchForService.isEmpty{
                            if numberOfItems > 4{
                                let block = serviceInCategory.value.sorted(by: {$0.id < $1.id})
                                LazyVGrid(columns:[GridItem(), GridItem()]) {
                                    ForEach(0...currentNumberInView, id:\.self){
                                        let service = block[$0]
                                        Button(action: {
                                            Task{
                                                //currentArticle = card
                                                withAnimation(.spring()){
                                                    showPage = article.set(service)
                                                }
                                            }
                                        }, label: {
                                            VStack(alignment:.center){
                                                VStack(alignment: .center, spacing: 5) {
                                                    Spacer()
                                                    VStack{
                                                        Text("\(service.name)")
                                                            .font(.custom("Ubuntu", size: 20))
                                                            .padding(.horizontal)
                                                        Text("\(service.cost.formatted(.currency(code: "EUR")))")
                                                            .padding(.horizontal)
                                                    }
                                                    .padding(.horizontal,2)
                                                    .padding(.vertical, 5)
                                                    .background(Material.bar.shadow(ShadowStyle.drop(radius: 10)))
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .offset(y:-20)
                                                }
                                                .frame(maxWidth: .infinity, alignment:.center)
                                            }
                                            
                                            //.shadow(radius: 5)
                                            .frame(height:120*16/9)
                                            .background{
                                                Image(uiImage: (article.images[service.illustration] ?? UIImage(named: "logo120"))!)
                                                    .resizable()
                                                    .clipped()
                                                    .scaledToFill()
                                                //.frame(maxWidth: 150)
                                                //.offset(x:0, y:-10)
                                                //.matchedGeometryEffect(id: "service", in: namespace)
                                            }
                                            .background(Material.ultraThin.shadow(ShadowStyle.drop(radius: 20)))
                                            .clipShape(RoundedRectangle(cornerRadius: 20), style: .init(eoFill: true))
                                            .padding(.bottom,10)
                                        })
                                        .tint(.primary)
                                        .shadow(color: .gray, radius: 5)
                                    }
                                    
                                    // + Button to see more or less
                                    Button {
                                        if currentNumberInView < numberOfItems-1{
                                            currentNumberInView = numberOfItems - 1
                                        }else{
                                            currentNumberInView = 2
                                        }
                                    } label: {
                                        VStack(spacing:2){
                                            Image(systemName: currentNumberInView < numberOfItems-1 ? "plus.circle.fill" : "minus.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80)
                                            
                                            
                                            Text(currentNumberInView == 2 ? "Voir plus" : "Voir moins")
                                        }
                                        .tint(Color("xpress"))
                                        
                                    }
                                }
                            }else{
                                if numberOfItems == 1{
                                    // Show articles in grid
                                    ForEach(serviceInCategory.value.sorted(by: {$0.id < $1.id}), id:\.self) { service in
                                        Button {
                                            Task{
                                                //currentArticle = card
                                                withAnimation(.spring()){
                                                    showPage = article.set(service)
                                                }
                                            }
                                        } label: {
                                            VStack(alignment:.center){
                                                VStack(alignment: .center, spacing: 5) {
                                                    Spacer()
                                                    VStack{
                                                        Text("\(service.name)")
                                                            .font(.custom("Ubuntu", size: 20))
                                                            .padding(.horizontal)
                                                        Text("\(service.cost.formatted(.currency(code: "EUR")))")
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
                                            .background{
                                                Image(uiImage: (article.images[service.illustration] ?? UIImage(named: "logo120"))!)
                                                    .resizable()
                                                    .clipped()
                                                    .scaledToFill()
                                            }
                                            .background(Material.ultraThin)
                                            .clipShape(RoundedRectangle(cornerRadius: 20), style: .init(eoFill: true))
                                            .padding(.bottom,10)
                                        }
                                        .tint(.primary)
                                        .shadow(color: .gray, radius: 5)
                                    }
                                }else
                                if numberOfItems > 1{
                                    LazyVGrid(columns: gridLayout) {
                                        ForEach(serviceInCategory.value.sorted(by: {$0.id < $1.id}), id:\.self){ service in
                                            Button {
                                                Task{
                                                    //currentArticle = card
                                                    withAnimation(.spring()){
                                                        showPage = article.set(service)
                                                    }
                                                }
                                            } label: {
                                                VStack(alignment:.center){
                                                    VStack(alignment: .center, spacing: 5) {
                                                        Spacer()
                                                        VStack{
                                                            Text("\(service.name)")
                                                                .font(.custom("Ubuntu", size: 20))
                                                                .padding(.horizontal)
                                                            Text("\(service.cost.formatted(.currency(code: "EUR")))")
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
                                                .background{
                                                    Image(uiImage: (article.images[service.illustration] ?? UIImage(named: "logo120"))!)
                                                        .resizable()
                                                        .clipped()
                                                        .scaledToFill()
                                                    //.frame(maxWidth: 150)
                                                    //.offset(x:0, y:-10)
                                                    //.matchedGeometryEffect(id: "service", in: namespace)
                                                }
                                                .background(Material.ultraThin)
                                                .clipShape(RoundedRectangle(cornerRadius: 20), style: .init(eoFill: true))
                                                .padding(.bottom,10)
                                            }
                                            .tint(.primary)
                                            .shadow(color: .gray, radius: 5)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.bottom)
            }
            if !searchForService.isEmpty{
                ForEach(article.SortBy(searchForService).sorted(by: {$0.id < $1.id}), id: \.self) { card in
                    VStack(alignment:.center){
                        VStack(alignment: .center, spacing: 5) {
                            Spacer()
                            VStack{
                                Text("\(card.name) " + "(\(card.categories))")
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
                    .background{
                        Image(uiImage: (article.images[card.illustration] ?? UIImage(named: "logo120"))!)
                            .resizable()
                            .clipped()
                            .scaledToFill()
                    }
                    .background(Material.ultraThin)
                    .clipShape(RoundedRectangle(cornerRadius: 20), style: .init(eoFill: true))
                    .padding(.bottom,10)
                    .onTapGesture {
                        Task{
                            //currentArticle = card
                            withAnimation(.spring()){
                                showPage = article.set(card)
                            }
                        }
                    }
                }
            }
            
            
        }
        .padding(.bottom, 100)
        
        //.padding(.horizontal, 10)
        //.onAppear(perform: fetchModel.fetchSewing)
        .onAppear{
            Task{
                await article.fetch()
            }
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
                            Label(searchForService.isEmpty ? "Populaires":"Recherche", systemImage: "flame.fill")
                                .font(Font.custom("Ubuntu", size: 25).bold())
                                .opacity(selectedCategory == "" ? 1 : 0.8)
                                .foregroundColor(selectedCategory.isEmpty ? Color.orange : Color.primary)
                        }.onTapGesture {
                            withAnimation(.easeInOut){
                                selectedCategory = ""
                            }
                        }
                        //Catégories
                        ForEach(article.GetCategories().sorted(by: <), id: \.self) { cat in
                            VStack{
                                Text("\(cat)")
                                    .font(.title2)
                                    .bold(true)
                                    .foregroundColor(selectedCategory == cat ? Color.primary : .secondary)
                                    .opacity(selectedCategory == cat ? 1 : 0.8)
                                    .padding(.horizontal)
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
            .padding(.horizontal)
            
        }
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
                            VStack{
                                HStack (spacing: 0, content: {
                                    Text("Bonjour \(utilisateur.this.surname),")
                                        .font(Font.custom("Ubuntu", size: 30,relativeTo: .title))
                                })
                                
                            }
                            
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
            .environmentObject(Article())
            .environmentObject(Utilisateur())
    }
}
