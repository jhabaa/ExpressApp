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
    @EnvironmentObject var appSettings:AppSettings
    @StateObject private var focusState = focusObjects()
    @FocusState private var focusedTextEditor: Bool
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
            //all services by categories
            Divider()
            //Search section
            Section {
                //all services by categories
                if !_search.isEmpty{
                    Section("Resultats") {
                        ForEach(article.all.sorted(by: {$0.id < $1.id}), id: \.self) { service in
                            //Set a section with category as title
                            if (service.categories.contains(_search) || service.name.contains(_search) || service.description.contains(_search)){
                                
                                NavigationLink {
                                    ServiceModifierView(service:service)
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
            List(article.all.sorted(by: {$0.id < $1.id}), id:\.self) { service in
                NavigationLink(service.name, value: service)
                
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button("Supprimer",role:.destructive){
                        //delete service code
                        appSettings.loading = true
                        Task{
                            appSettings.connection_error = !(await service.Delete()) //Delete this service and show error if happen
                            appSettings.connection_error = !(await article.fetch()) //Actualize services list
                            appSettings.loading = appSettings.connection_error ? false : true
                        }
                        
                    }
                    .tint(.red)
                }
                .frame(maxWidth: .infinity)
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
            .navigationDestination(for: Service.self) { service in
                ServiceModifierView(service:service)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {

                NavigationLink {
                    AddArticleView()
                } label: {
                    Label("Ajouter", systemImage: "plus.circle.fill")
                        .labelStyle(.titleAndIcon)
                        .background(.gray)
                        .buttonStyle(.borderedProminent)
                }
            }
            .listStyle(.plain)
            .edgesIgnoringSafeArea([.top, .bottom])
            .navigationTitle("Tous les services")
            
            .padding(.bottom, 100)
        }
        .navigationViewStyle(.columns)
        .environmentObject(focusState)
        .searchable(text: $_search)
        //.navigationBarTitleDisplayMode(.)
        .onAppear {
            dicoInfo = fetchModel.GetServiceMessage()
            oldService = article.this
            /*Task{
                await UserData.save(user:completion:)
            }*/
            Task{
                appSettings.connection_error =  !(await article.fetch())
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

    
    @State var showingImagePicker = false
    @State var inputImage:UIImage?
    //@State var price:String=String()
    @ViewBuilder
    func AddArticleView() -> some View{
        NavigationStack {
            Form{
                Section(header:Text("Informations sur le service")){
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
                    .foregroundStyle(article.is_acceptable(article.this) ? .blue : .red)
                    Toggle(isOn: $newCategory) {Text("Créer Nouvelle Categorie")}
                        .toggleStyle(.button)
                    //MARK: Picker in existing caterories
                    if newCategory{
                        TextField("Categorie", text: $article.this.categories)
                    }else{
                        Picker(selection: $article.this.categories, label: Text("Catégorie")) {
                            ForEach(article.GetCategories().sorted(by: <), id:\.self) {category in
                                Text(category).tag(category)
                            }
                        }
                    }
                    
                }
                //MARK: Section for price and time
                    Section(header:Text("Prix en € et durée de traitement")){
                    TextField("Prix en €", text: .init(get: {
                        price
                    }, set: { Value in
                        price = Value.filter({$0.isNumber || $0 == "."})
                        if !price.isEmpty{
                            article.this.cost = Decimal(string: price)!
                        }
                    }))
                    .keyboardType(.decimalPad)
                    TextField("", value: $article.this.time, format: .number, prompt: Text("Durée de traitement"))
                        
                }
                Section(header:Text("Description")){
                    Toggle("Description ?", isOn: $description)
                    if description{
                        TextEditor(text: .init(get: {
                            article.this.description
                        }, set: { v in
                            if (String(v).allSatisfy({$0.isASCII})){
                                article.this.description = v
                            }
                        }))
                        .frame(height: 150)
                        .focused($focusedTextEditor)
                        .onReceive(article.this.description.publisher.last()) {
                                        if ($0 as Character).asciiValue == 10 { // ASCII 10 = newline
                                            focusedTextEditor = false // unfocus TextEditor to dismiss keyboard
                                            article.this.description.removeLast() // remove newline at end to prevent retriggering...
                                        }
                                    }
                        .submitLabel(SubmitLabel.done)
                        .animation(.spring, value: description)
                    }
                }
                Button(action: {
                    self.showingImagePicker = true
                }, label: {
                    Text("Sectionner une image")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
            }
            .onSubmit {
                //focusedTextEditor = false // Hide keyboard after pressing Done
            }
        }
        .toolbar(content: {
                Button {
                    // Save this service
                    appSettings.loading = true
                    Task{
                        if !article.this.withDescription{
                            article.this.description = "."
                        }
                        appSettings.connection_error = !(await article.PushService(inputImage))
                        if !appSettings.connection_error{
                            //Show notification
                            alerte.NewNotification(.amber, "Nouvel article ajouté", UIImage(systemName: "cart"))
                            
                            appSettings.connection_error = !(await article.fetch())
                            appSettings.loading = false
                        }
                         
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Enregister")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!article.is_acceptable(article.this))
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
        .ignoresSafeArea(.container)
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
            .environmentObject(AppSettings())
    }
}
