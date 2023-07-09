//
//  ServicesAllView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 03/04/2023.
//

import SwiftUI

struct ServicesAllView: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var article:Article
    @StateObject private var focusState = focusObjects()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var alerte:Alerte
    @Namespace var namespace:Namespace.ID
    @State var selectedCategory:String = ""
    @State private var date = Date()
    @State private var showSheet = false
    @State var showSewing:Bool = false
    @State var showWash:Bool = false
    @State var showShoes:Bool = false
    @State var showPage:Bool = false
    @State var oldService:Service = Service()
    @EnvironmentObject var fetchModel : FetchModels
    @State var gridLayout: [GridItem] = [ GridItem(.flexible()),GridItem(.flexible())]
    @State var rows = [GridItem(.adaptive(minimum: 200)), GridItem(.adaptive(minimum: 150))]
    @State var dicoInfo:[String:String] = [:]
    @State var S:CGSize = CGSize.init()
    //@State var service:[SERVICE] = [SERVICE.init()]
    @State private var selectedImage: UIImage?
    @State private var seachService:Service = Service()

    @State private var showImagePicker: Bool = false
    @State private var edit_mode:Bool = false
    @State private var _search:String=String()
    private let formatterDec: NumberFormatter = {
            let formatterDec = NumberFormatter()
            formatterDec.numberStyle = .decimal
            //formatter.minimumFractionDigits = 2
            //formatter.maximumFractionDigits = 2
            return formatterDec
        }()
    private let formatterInt: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            return formatter
        }()
    var body: some View {
        NavigationStack {
            ScrollView {
                //Search section
                Section {
                    //Search bar
                    TextField("rechercher un service", text: $_search)
                        .padding()
                        .frame(alignment: .center)
                        .multilineTextAlignment(.center)
                                                
                        .background(.bar)
                        .clipShape(Capsule())
                        .padding()
                        
                        .padding([.top, .bottom], 150)
                    //all services by categories
                    if !_search.isEmpty{
                        Section("Resultats") {
                            ForEach(article.all.sorted(by: {$0.id < $1.id}), id: \.self) { service in
                                //Set a section with category as title
                                if (service.categories.contains(_search) || service.name.contains(_search) || service.description.contains(_search)){
                                    
                                    NavigationLink {
                                        ArticleView(service:service)
                                    } label: {
                                        HStack{
                                            Image(uiImage: (article.images[service.illustration] ?? UIImage(named: "logo120"))!)
                                                .resizable()
                                                .frame(width: 70, height:70)
                                                .scaledToFill()
                                                .cornerRadius(20)
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(service.name)
                                                    .fontWeight(.bold)
                                                Text("#\(service.id)")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .badge("price")
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button("Supprimer"){
                                            //delete service code
                                            let response = Task{
                                               return await service.Delete()
                                            }
                                            print(response)
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                        
                    }
                        

                }
                
                
               // Label("Swiper à partir de la gauche pour supprimer un article", systemImage: "info.circle")
                    //.font(.caption2)
                    
                    
                //all services by categories
                ForEach(article.GetCategories().sorted(by: <), id:\.self) { category in
                    
                    Section {
                        ForEach(article.all.sorted(by: {$0.id < $1.id}), id: \.self) { service in
                            
                            //Set a section with category as title
                            if (service.categories == category){
                                NavigationLink(value: service) {
                                    HStack{
                                             Image(uiImage: (article.images[service.illustration] ?? UIImage(named: "logo120"))!)
                                                 .resizable()
                                                 .frame(width: 70, height:70)
                                                 .scaledToFill()
                                                 .cornerRadius(20)
                                             
                                                 Text(service.name)
                                                     .font(.caption)
                                                     .fontWeight(.bold)
                                    }
                                    .padding(.leading, 30)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button("Supprimer",role:.destructive){
                                        //delete service code
                                        let response = Task{
                                           return await service.Delete()
                                        }
                                        print(response)
                                        //actualise services
                                        Task{
                                            await article.fetch()
                                        }
                                        
                                    }
                                    .tint(.red)
                                }
                                .frame(maxWidth: .infinity)
                                
                            }
                        }
                    }header:{
                        VStack(alignment:.leading){
                            Text(category)
                                .padding()
                                .background(.bar)
                        }
                        .frame(maxWidth: .infinity, alignment:.leading)
                      
                            
                    }
                }
            }
            .toolbar {
                NavigationLink {
                    AddArticleView()
                } label: {
                    Label("Ajouter", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
            }
            .listStyle(.plain)
            .edgesIgnoringSafeArea(.top)
            .navigationDestination(for: Service.self) { D in
                ArticleView(service:D)
            }
        }
        .navigationViewStyle(.columns)
        .environmentObject(focusState)
        //.navigationBarTitleDisplayMode(.)
        .onAppear {
            dicoInfo = fetchModel.GetServiceMessage()
            oldService = article.this
            /*Task{
                await UserData.save(user:completion:)
            }*/
            Task{
                await article.fetch()
            }
            
        }
        .background(.bar)
    }
    
    @ViewBuilder
    func HeaderView(proxyScroll:CGSize)->some View{
        GeometryReader {
            let minY = $0.frame(in: .named("SCROLL")).minY
            var progress = minY / (proxyScroll.height * 0.5)
            VStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:20){
                        //Toutes catégories
                        VStack{
                            if (selectedCategory == ""){
                                
                            }
                            Text("Tout")
                                .font(Font.custom("Ubuntu", size: 25).bold())
                                .opacity(selectedCategory == "" ? 1 : 0.8)
                        }.onTapGesture {
                            withAnimation(.easeInOut){
                                selectedCategory = ""
                            }
                        }
                        //Catégories
                        ForEach(article.GetCategories().sorted(by: <), id: \.self) { cat in
                            VStack{
                               
                                Text("\(cat)")
                                    .font(Font.custom("Ubuntu", size: 25).bold())
                                    .opacity(selectedCategory == cat ? 1 : 0.8)
                                    .padding(20)
                            }
                            .frame(maxWidth: .infinity, alignment:.center)
                            .background(.bar)
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
        
    }
    
    @ViewBuilder
    func ServicesList() -> some View {
        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(article.all.sorted(by: {$0.id < $1.id}), id: \.self) {
                    card in
                    if selectedCategory.isEmpty{
                        VStack{
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(card.name)")
                                    .font(.custom("Ubuntu", size: 30))
                                    .padding(.horizontal)
                                HStack(alignment: .bottom, spacing: 20) {
                                    Spacer()
                                    Text("\(card.cost.formatted(.currency(code: "EUR")))")
                                }
                                .padding()
                            }
                            .clipped()
                            .background(.ultraThinMaterial)
                        }.frame(width: .infinity, height: 200, alignment: Alignment.bottom)
                            
                            .background {
                                AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(card.name)") , content: { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        //.renderingMode(.original)
                                        .clipped()
                                }, placeholder: {
                                    Image("AppIcon")
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                    
                                })
                                .matchedGeometryEffect(id: "\(card.name)", in: namespace)
                                
                            }
                            .cornerRadius(20)
                            .onTapGesture {
                                Task{
                                    //userdata.currentArticle = card
                                    withAnimation(.spring()){
                                        showPage = true
                                        
                                    }
                                }
                            }
                    }else
                    if(card.categories.contains(selectedCategory)){
                        VStack{
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(card.name)")
                                    .font(.custom("Ubuntu", size: 30))
                                    .padding(.horizontal)
                                HStack(alignment: .bottom, spacing: 20) {
                                    Spacer()
                                    Text("\(card.cost.formatted(.currency(code: "EUR")))")
                                }
                                .padding()
                            }
                            .clipped()
                            .background(.ultraThinMaterial)
                        }.frame(width: .infinity, height: 200, alignment: Alignment.bottom)
                            
                            .background {
                                AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(card.name)") , content: { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        //.renderingMode(.original)
                                        .clipped()
                                }, placeholder: {
                                    Image("AppIcon")
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                    
                                })
                                .matchedGeometryEffect(id: "\(card.name)", in: namespace)
                                
                            }
                            .cornerRadius(20)
                            .onTapGesture {
                                Task{
                                    //userdata.currentArticle = card
                                    withAnimation(.spring()){
                                        showPage = true
                                        
                                    }
                                }
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        //.onAppear(perform: fetchModel.fetchSewing)
    }
    
    //@ViewBuilder
    /*
    func Categories() -> some View {

            //let minY = Proxy.frame(in: .named("SCROLL")).minY
            //var progress = minY / (proxyScroll.height * 400)

            VStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:20){
                        //Toutes catégories
                        VStack{
                            if (selectedCategory == ""){
                                
                            }
                            Text("Pour vous")
                                .font(Font.custom("Ubuntu", size: 25).bold())
                                .opacity(selectedCategory == "" ? 1 : 0.8)
                        }.onTapGesture {
                            withAnimation(.easeInOut){
                                selectedCategory = ""
                            }
                        }
                        //Catégories
                        ForEach(fetchModel.GetCategories().sorted(by: <), id: \.self) { index in
                        VStack(alignment: .center, spacing: 20) {
                            Text(index)
                                .font(.custom("Ubuntu", size: 20))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                                .padding([.bottom, .horizontal],10)
                        }.frame(width: 150 , height: 150, alignment:.bottom)
                            .background{
                                
                                AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(index)") , content: { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .clipped()
                                        .grayscale(index == selectedCategory ? 0 : 1)
                                }, placeholder: {
                                    ProgressView()
                                })
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                            .shadow(color:.white,radius: index==selectedCategory ? 1 : 0)
                            .onTapGesture {
                                withAnimation (.spring()) {
                                    selectedCategory = index
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
            }
            .frame(height: 150, alignment:.bottom)
        
            //.offset(y: minY < 100 ? -minY : 0).animation(.easeInOut, value: minY)
            .zIndex(10)
            
    }
    */
    @ViewBuilder
    func Greetings(proxy:CGSize) -> some View{
        GeometryReader { GeometryProxy in
            let minY = GeometryProxy.frame(in: .named("SCROLL")).minY
            var progress = minY / (proxy.height * 0.6)
            VStack{
                Image("page 1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.width, height: proxy.height + (minY > 0 ? minY : 0))
                    .clipped()
                    .overlay(content: {
                        ZStack (alignment: .top, content: {
                            Rectangle().fill(.linearGradient(colors: [Color("fond").opacity(0 - progress),
                                                                      Color("fond").opacity(0.1 - progress),
                                                                      Color("fond").opacity(0.3 - progress),
                                                                      Color("fond").opacity(0.5 - progress),
                                                                      Color("fond").opacity(0.7 - progress),
                                                                      Color("fond").opacity(1),]
                                                             , startPoint: .top, endPoint: .bottom))
                            HStack (spacing: 0, content: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .tint(.secondary)
                                    .clipShape(Circle())
                                    .frame(width: 20)
                                    .padding(.horizontal)
                                //Text("Bonjour \(utilisateur.this.name),")
                                    //.font(Font.custom("Ubuntu", size: 30,relativeTo: .title))
                            })
                            .padding(.top, 210)
                            .opacity(minY == 0 ? 1 : (1 + progress))
                            .offset(y: -minY)
                        })
                    })
                    .offset(y : -minY) // L'image reste figée
            }.frame(height: GeometryProxy.size.height * 40 + GeometryProxy.safeAreaInsets.top)
        }
    }
    
    @State var new_Price:Decimal = Decimal()
    @State var quantity : Int = 0
    @State var price:String=String()
    @State var description:Bool = false
    @State var newCategory:Bool = false
    @available(iOS 16.0, *)
    @ViewBuilder
    func ArticleView(service:Service = Service()) -> some View{
        ScrollView{
                
            CustomTextField(_text: $article.this.name, _element: "mot de passe",hideMode:false,type:.text, name:"Nom du service")
                .disabled(!edit_mode)
                Toggle(isOn: $newCategory) {Text("Nouvelle Categorie")}
                .disabled(!edit_mode)
                if newCategory{
                    
                    CustomTextField(_text: $article.this.categories, _element: "Catégorie",hideMode:false,type:.text, name:"Nouvelle Catégorie")
                        .disabled(!edit_mode)
                }else{
                    
                    Section{
                        
                    }footer:{
                        //all existing categories to simplify filling
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 20) {
                                ForEach(article.GetCategories().sorted(by: <), id:\.self) {category in
                                    Text(category)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .background(article.this.categories == category ? .blue : .blue.opacity(0.0))
                                        .onTapGesture {
                                            //assing it
                                            article.this.categories = category
                                        }
                                }
                            }
                        }
                    }
                }
               
                Section {} header: {
                    Text("Prix de l'article et delai de traitement")
                }footer:{
                    HStack(content: {
                        TextField("Prix en €", text: .init(get: {
                            price
                        }, set: { Value in
                            price = Value.filter({$0.isNumber || $0 == "."})
                            if !price.isEmpty{
                                article.this.cost = Decimal(string: price)!
                            }
                        }))
                        //TextField("Prix en €", value: $new_service.cost, format: .currency(code: ""))
                            .keyboardType(.decimalPad)
                            .shadow(radius: 1)
                            .font(.system(size: 20))
                            .padding()
                            .background()
                            .clipShape(Capsule())
                        Picker("Nombre de jours requis", selection: $article.this.time) {
                            ForEach(0..<100){day in
                                Text("\(day)")
                            }
                        }
                        .pickerStyle(.automatic)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    })
                }
                
                //message associé
                
                Toggle(isOn: $description) {
                    Text("Description ?")
                }
                .onChange(of: description) { V in
                    if V{
                        article.this.description = "ras"
                    }
                }
                if description{
                    Section("Message associé au service"){
                        TextField("\(article.this.description)", text: .init(get: {
                            article.this.description
                        }, set: { v in
                            if (String(v).allSatisfy({$0.isASCII})){
                                article.this.description = v
                            }
                        }))
                    }
                }
                Section{}
            header:{
                Text("Choisir une illustration")
            }
            footer:{
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(article.images.keys.sorted(by: <), id: \.self) { name in
                            Image(uiImage: article.images[name]!)
                                .resizable()
                                .frame(width: 100, height:100)
                                .padding()
                                .onTapGesture {
                                    article.this.illustration = name
                                }
                                .scaleEffect(article.this.illustration == name ? 1.2: 1)
                                .shadow(color: Color("xpress"), radius: article.this.illustration == name ? 10: 0)
                        }
                    }
                }
                .disabled(!edit_mode)
            }
            
                Button("Supprimer l'article"){
                    Task{
                        let t = await article.this.Delete()
                        // if article has been deleted properly
                    }
                    
                
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
                .tint(.red)
            
            .listStyle(.plain)
            
        }
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
                Button {
                    if (edit_mode){
                        Task{
                            edit_mode = await !article.Put_Service(service: article.this)
                            await article.fetch()
                        }
                        //Show notification
                        alerte.this.text = "Article mis à jour"
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            alerte.this.text = String()
                        })
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        withAnimation(.spring()) {
                            edit_mode.toggle()
                        }
                    }
                    
                } label: {
                    Text(edit_mode == false ? "Modifier" : article.this == service ? "Annuler" : "Enregister")
                        
                }
                .tint(edit_mode ? .green : .blue)

                
        })
        .onAppear{
            //selected_service = service
            print(service)
            article.this = service
        }
        .onDisappear {
            article.this = Service()
        }

        
    }
    
    @State var showingImagePicker = false
    @State var inputImage:UIImage?
    //@State var price:String=String()
    @ViewBuilder
    func AddArticleView() -> some View{
        GeometryReader { GeometryProxy in
            ScrollView{
                    Section{
                        TextField("Nom du produit", text:.init(get: {
                            article.this.name
                        }, set: { Value in
                            article.this.name = Value
                            //Create illustration name
                            article.this.illustration =
                            article.this.name.filter({
                                $0.isLetter && $0.isASCII && !$0.isPunctuation
                            })
                        }))
                        .frame(width: GeometryProxy.size.width)
                        .font(.custom("Ubuntu", size: 40))
                        
                        .bold()
                        .foregroundStyle(article.is_acceptable(article.this) ? .blue : .red)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.4)
                    }

                Toggle(isOn: $newCategory) {Text("Nouvelle Categorie")}
                
                if newCategory{
                    TextField("Categorie", text: $article.this.categories)
                        .contrast(0.1)
                        .foregroundColor(.gray)
                }else{
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 20) {
                            ForEach(article.GetCategories().sorted(by: <), id:\.self) {category in
                                Text(category)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .onTapGesture {
                                        //assing it
                                        article.this.categories = category
                                    }
                            }
                        }
                        
                    }
                }
                    
                    Section {
                        
                    } header: {
                        Text("Prix de l'article et delai de traitement")
                    }footer:{
                        HStack(content: {
                            TextField("Prix en €", text: .init(get: {
                                price
                            }, set: { Value in
                                price = Value.filter({$0.isNumber || $0 == "."})
                                if !price.isEmpty{
                                    article.this.cost = Decimal(string: price)!
                                }
                                
                            }))
                            //TextField("Prix en €", value: $new_service.cost, format: .currency(code: ""))
                            .keyboardType(.decimalPad)
                                .shadow(radius: 1)
                                .font(.system(size: 20))
                                .padding()
                                .background()
                                .clipShape(Capsule())
                            Picker("Nombre de jours requis", selection: $article.this.time) {
                                ForEach(0..<100){day in
                                    Text("\(day)")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        })
                    }
                    
                    //Message to user
                    Section {} footer: {
                        //message associé
                        TextEditor(text: .init(get: {
                            article.this.description
                        }, set: { v in
                            if (String(v).allSatisfy({$0.isASCII})){
                                article.this.description = v
                            }
                        }))
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    //Add illustration
                    Section {} footer: {
                        Button(action: {
                            self.showingImagePicker = true
                        }, label: {
                            HStack{
                                Text("Image")
                                    .padding()
                                    .background(Color("xpress"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                inputImage.map {
                                    Image(uiImage: $0)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height:150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .frame(width: .infinity, alignment: .center)
                        })
                       
                    }
            }
        }
        
        .navigationTitle(article.this.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
                Button {
                    // Save this service
                    Task{
                        let response = await article.PushService(inputImage)
                        if response{
                            //Show notification
                            alerte.this.text = "Nouvel Article ajouté"
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                alerte.this.text = String()
                            })
                        }
                         await article.fetch()
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Enregister")
                }
                .disabled(!article.is_acceptable(article.this))
        })
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePickerView(selectedImage: $inputImage)
        })
        .background(LinearGradient(colors: [
            colorScheme == .dark ? .black : .white,
            colorScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.6),
            colorScheme == .dark ? .black.opacity(0.2) : .white.opacity(0.2),
       
        ], startPoint: .top, endPoint: .bottom))
        .background{
            Image(uiImage: (inputImage != nil) ? inputImage! : .init(imageLiteralResourceName: "Shoes4"))
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
        }
    }
    
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
            var progress = minY / (proxyScroll.height * 0.6)
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

@ViewBuilder
func backgroundImage(size:CGSize)->some View{
    GeometryReader {
        let minY = $0.frame(in: .named("scroll")).minY + $0.safeAreaInsets.top
        VStack{
            Image("page 1")
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                .grayscale(size.height + minY > 0 ? minY : 0)
                
        }
        .frame(height: $0.size.height * 40 + $0.safeAreaInsets.top)
    }
}



struct Previews_ServicesAllView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesAllView().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Article())
            .environmentObject(Alerte())
    }
}
