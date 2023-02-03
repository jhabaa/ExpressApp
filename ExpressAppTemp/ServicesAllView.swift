//
//  ServicesAllView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 03/04/2023.
//

import SwiftUI

struct ServicesAllView: View {
    @EnvironmentObject var userdata:UserData
    @Namespace var namespace:Namespace.ID
    @State var selectedCategory:String = ""
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
    //@State var service:[SERVICE] = [SERVICE.init()]
    @State private var selectedImage: UIImage?
    @State private var seachService:Service = Service()
    @State private var new_service:Service = Service()
    @State var selected_service:Service = Service()
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
        NavigationView {
            List {
                //Search section
                Section {
                    //Search bar
                    TextField("rechercher un service", text: $_search)
                    //all services by categories
                    if !_search.isEmpty{
                        Section("Resultats") {
                            ForEach(fetchModel.services, id: \.self) { service in
                                //Set a section with category as title
                                if (service.categories.contains(_search) || service.name.contains(_search) || service.description.contains(_search)){
                                    
                                    NavigationLink {
                                        ArticleView(service:service)
                                    } label: {
                                        HStack{
                                            Image(uiImage: (fetchModel.services_Images[service.illustration] ?? UIImage(named: "logo120"))!)
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
                        

                }header:{
                    Text("La recherche des articles cherche des correspondances dans les noms mais aussi dans les messages associés aux articles")
                }
                //all services by categories
                ForEach(fetchModel.GetCategories().sorted(by: <), id:\.self) { category in
                    
                    Section(category) {
                        ForEach(fetchModel.services, id: \.self) { service in
                            
                            //Set a section with category as title
                            if (service.categories == category){
                                
                                NavigationLink {
                                    ArticleView(service:service)
                                } label: {
                                    HStack{
                                        Image(uiImage: (fetchModel.services_Images[service.illustration] ?? UIImage(named: "logo120"))!)
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
            .toolbar {
                NavigationLink {
                    AddArticleView()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .cornerRadius(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                }
            }
        }
        .navigationViewStyle(.columns)
        .onAppear {
            dicoInfo = fetchModel.GetServiceMessage()
            /*Task{
                await UserData.save(user:completion:)
            }*/
            Task{
                await fetchModel.FetchServices()
            }
        }
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
        
    }
    
    @ViewBuilder
    func ServicesList() -> some View {
        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(fetchModel.services.sorted(by: {$0.id < $1.id}), id: \.self) {
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
                                    userdata.currentArticle = card
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
                                    userdata.currentArticle = card
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
    
    @ViewBuilder
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
                                Text("Bonjour \(userdata.currentUser.name),")
                                    .font(Font.custom("Ubuntu", size: 30,relativeTo: .title))
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
    @available(iOS 16.0, *)
    @ViewBuilder
    func ArticleView(service:Service = Service()) -> some View{
        VStack{
            List{
                Section("Nom du produit") {
                    TextField("Nom du produit", text: $selected_service.name)
                }
                Section{
                    TextField("Categorie", text: $selected_service.categories)
                        .contrast(0.1)
                        .foregroundColor(.gray)
                }footer:{
                    //all existing categories to simplify filling
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 20) {
                            ForEach(fetchModel.GetCategories().sorted(by: <), id:\.self) {category in
                                Text(category)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .onTapGesture {
                                        //assing it
                                        selected_service.categories = category
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
                            price = Value.filter({$0.isNumber || $0 == ","})
                            if !price.isEmpty{
                                selected_service.cost = Decimal(string: price)!
                            }
                            
                        }))
                        //TextField("Prix en €", value: $new_service.cost, format: .currency(code: ""))
                            .keyboardType(.numbersAndPunctuation)
                            .shadow(radius: 1)
                            .font(.system(size: 20))
                            .padding()
                            .background()
                            .clipShape(Capsule())
                        Picker("Nombre de jours requis", selection: $selected_service.time) {
                            ForEach(0..<100){day in
                                Text("\(day)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    })
                }
                
                //message associé
                Section("Message associé au service"){
                    TextField("", text: .init(get: {
                        selected_service.description
                    }, set: { v in
                        if (String(v).allSatisfy({$0.isASCII})){
                            selected_service.description = v
                        }
                    }))
                }
                
                Section{}
            header:{
                Text("Choisir une illustration")
            }
            footer:{
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(fetchModel.services_Images.keys.sorted(by: <), id: \.self) { name in
                            Image(uiImage: fetchModel.services_Images[name]!)
                                .resizable()
                                .frame(width: 100, height:100)
                                .padding()
                                .onTapGesture {
                                    selected_service.illustration = name
                                }
                                .scaleEffect(selected_service.illustration == name ? 1.2: 1)
                                .shadow(color: Color("xpress"), radius: selected_service.illustration == name ? 10: 0)
                        }
                    }
                }
                .disabled(!edit_mode)
            }
            
            }
        }
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
                Button {
                    if (edit_mode){
                        Task{
                            edit_mode = await !fetchModel.Put_Service(service: selected_service)
                        }
                    }else{
                        withAnimation(.spring()) {
                            edit_mode.toggle()
                        }
                    }
                    
                } label: {
                    Text(edit_mode == false ? "Modifier" : selected_service == service ? "Annuler" : "Enregister")
                        
                }
                .tint(edit_mode ? .green : .blue)

                
        })
        .onAppear{
            selected_service = service
        }
        
        /*
        GeometryReader { GeometryProxy in
            let size = GeometryProxy.size
            VStack(alignment:.leading){
                //name
                VStack(spacing:5){
                    TextField("Nom Recette", text: $userdata.currentArticle.NAME_SERVICE)
                        .font(.custom("Outfit", size: 50))
                        .fontWidth(.expanded)
                        .fontWeight(.heavy)
                        .contrast(0.9)
                    TextField("Categorie", text: $userdata.currentArticle.CATEGORY_SERVICE)
                        .font(.custom("Outfit", size: 50))
                        .fontWidth(.expanded)
                        .contrast(0.1)
                        .foregroundColor(.gray)
                    
                }
                .padding()
                .padding(.top, 100)
                .background(.ultraThinMaterial)
                .cornerRadius(50)
                .frame(maxWidth: .infinity, alignment:.leading)
                
                //Price
                HStack{
                    TextField("Prix", value: $userdata.currentArticle.COST_SERVICE, format: .currency(code: ""))

                        .font(.custom("Outfit", size: 100))
                        .padding(.horizontal)
                        .frame(width: 300)
                    VStack{
                        Text("€")
                        Text("l'unité")
                            
                    }
                    .multilineTextAlignment(.leading)
                    .font(.custom("Outfit", size: 30))
                    .padding(.horizontal, -50)
                    Spacer()
                }
                
                HStack{
                    TextField("Jours",value: $userdata.currentArticle.SIZE_SERVICE, formatter: formatterInt)
                        .font(.largeTitle)
                        .fontWidth(.condensed)
                        .fontWeight(.bold)
                        .frame(width: 50)
                    VStack{
                        Text("jours\nlivraison")
                    }
                }.frame(alignment: .leading)
                    .padding()
                    .background(Color("xpress"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                
            
            }
            .zIndex(3)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
            .clipped()
            .overlay(alignment: .topLeading) {
                Image(systemName: "arrow.backward.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 50)
                    .padding(.leading, 20)
                    .onTapGesture {
                        //userdata.Back()
                        showPage = false
                    }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .background(.ultraThinMaterial)
        .background{
            AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(userdata.currentArticle.NAME_SERVICE)") , content: { image in
                image.resizable()
                    
                    .cornerRadius(50)
                    
                    .padding(10)
                    //.frame(height: size.height/1.5)
                    
            }, placeholder: {
                ProgressView()
                        .cornerRadius(50)
                        .padding(10)
                        .scaledToFill()
                        //.frame(height: size.height/1.5)
            })
            .matchedGeometryEffect(id: "\(userdata.currentArticle.NAME_SERVICE)", in: namespace)
        }
        
        .ignoresSafeArea()
        .onAppear{
            quantity = 0
            withAnimation(.spring()){
                userdata.taskbar = false
                //new_Price = currentArticle.COST_SERVICE
            }
        }
        .onDisappear{
            withAnimation(.spring()){
                userdata.taskbar = true
            }
        }
        .overlay(alignment: .bottom) {
            HStack{
                Text("Choisir une image")
                    .underline()
                    .onTapGesture {
                        self.showImagePicker = true
                    }
                Button {
                    Task{
                        print(userdata.currentArticle)
                    
                        showPage = await !fetchModel.Put_Service(service: userdata.currentArticle)
                        //fetchModel.fetchSewing()
                    }
                } label: {
                    Label("Appliquer", systemImage: "checkmark").padding()
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(Color("xpress"))

            }
            .padding()
            .background{
                RoundedRectangle(cornerRadius: 50)
                    .fill(.ultraThinMaterial)
            }
        }*/
        
    }
    
    @State var showingImagePicker = false
    @State var inputImage:UIImage?
    //@State var price:String=String()
    @ViewBuilder
    func AddArticleView() -> some View{
        VStack{
            List {
                Section{
                    TextField("Nom du produit", text:.init(get: {
                        new_service.name
                    }, set: { Value in
                        new_service.name = Value
                        //Create illustration name
                        new_service.illustration =
                        new_service.name.filter({
                            $0.isLetter && $0.isASCII && !$0.isPunctuation
                        })
                    }))
                    
                        .foregroundStyle(new_service.is_acceptable ? .blue : .red)
                }header: {
                    Text("Nom du produit")
                }
            footer:{
                if !new_service.is_acceptable{
                    Label("Ce produit existe déjà", systemImage: "info.circle")
                        .foregroundStyle(.red)
                }
                
            }
                Section{
                    TextField("Categorie", text: $new_service.categories)
                        .contrast(0.1)
                        .foregroundColor(.gray)
                }footer:{
                    //all existing categories to simplify filling
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 20) {
                            ForEach(fetchModel.GetCategories().sorted(by: <), id:\.self) {category in
                                Text(category)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .onTapGesture {
                                        //assing it
                                        new_service.categories = category
                                    }
                            }
                        }
                        
                    }
                }
                
                //Price
                
                Section {
                    
                } header: {
                    Text("Prix de l'article et delai de traitement")
                }footer:{
                    HStack(content: {
                        TextField("Prix en €", text: .init(get: {
                            price
                        }, set: { Value in
                            price = Value.filter({$0.isNumber || $0 == ","})
                            if !price.isEmpty{
                                new_service.cost = Decimal(string: price)!
                            }
                            
                        }))
                        //TextField("Prix en €", value: $new_service.cost, format: .currency(code: ""))
                            .keyboardType(.numbersAndPunctuation)
                            .shadow(radius: 1)
                            .font(.system(size: 20))
                            .padding()
                            .background()
                            .clipShape(Capsule())
                        Picker("Nombre de jours requis", selection: $new_service.time) {
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
                        new_service.description
                    }, set: { v in
                        if (String(v).allSatisfy({$0.isASCII})){
                            new_service.description = v
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
                
                //Choix de l'illustration
                /*
                Section{}
            header:{
                Text("Choisir une illustration")
            }
            footer:{
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(fetchModel.services_Images.keys.sorted(by: <), id: \.self) { name in
                            Image(uiImage: fetchModel.services_Images[name]!)
                                .resizable()
                                .frame(width: 100, height:100)
                                .padding()
                                .onTapGesture {
                                    new_service.illustration = name
                                }
                                .scaleEffect(new_service.illustration == name ? 1.2: 1)
                                .shadow(color: Color("xpress"), radius: new_service.illustration == name ? 10: 0)
                        }
                    }
                }
            }*/
            }
        }
        .navigationTitle(new_service.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
                Button {
                    // Save this service
                    Task{
                        await fetchModel.PushService(service: new_service,inputImage)
                    }
                } label: {
                    Text("Enregister")
                }
                .disabled(!new_service.is_acceptable)
        })
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePickerView(selectedImage: $inputImage)
        })
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
    }
}
