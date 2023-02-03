//
//  AdminShowAllView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 07/04/2022.
//

import SwiftUI

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()

    let standard = UINavigationBarAppearance()
        standard.configureWithTransparentBackground()
        standard.backgroundColor = .clear//When you scroll or you have title (small one)
        standard.titleTextAttributes = [.foregroundColor : UIColor.white]
       // standard.backgroundImage = UIImage(named: "Blanc1")?.resizableImage(withCapInsets: .zero)
        
    let compact = UINavigationBarAppearance()
       // compact.backgroundColor = .white //compact-height
        

    let scrollEdge = UINavigationBarAppearance()
        scrollEdge.backgroundColor = .clear //When you have large title
       // scrollEdge.backgroundImage = UIImage(named: "Blanc1")?.resizableImage(withCapInsets: .zero)
       // scrollEdge.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
      
        //UINavigationBarAppearance().backgroundImage = UIImage(named: "Blanc1")
       // UINavigationBar.appearance().tintColor = UIColor.white.resolvedColor(with: .current)
        
    navigationBar.standardAppearance = standard
    navigationBar.compactAppearance = compact
    navigationBar.scrollEdgeAppearance = scrollEdge
        
       
        
 }
}
/*
struct AdminShowAllView: View {
    //@Binding var homePage:Bool
    //@Binding var currentPage:Bool
    @StateObject private var userData = UserData()
    @State var commandDetail:Bool = false
    @State var searchTitle:String
    @State var searchText:String = ""
    @State var selectedCategory:String = ""
    @StateObject var fetchModel=FetchModels()
    //@State var indexToShow:COMMAND_HAS_USER = COMMAND_HAS_USER(command_id: 0, user: 0)
    @State var showAddView:Bool=false
    @State var showAddCoupon:Bool = false
    @State var CODE_COUPON:String  = ""
    @State var COST:Decimal  = Decimal.zero
    @State var ACTIVE:Int  = 0
    @State var selectedService = SERVICE.init()
    @State var activeService:Bool = false
    @State var userViewed:User = User.init()
    let phoneFormatter: NumberFormatter = {
        let phoneFormatter = NumberFormatter()
        phoneFormatter.numberStyle = .none
    
        return phoneFormatter
    }()
    @State var NewsLetter: Bool = false
    @State var modificatioMode:Bool = false
    @Namespace var namespace : Namespace.ID
    @State var showDetailUserView:Bool = false
    @State var suppressMode:Bool = false
    var body: some View {
        GeometryReader { GeometryProxy in
            NavigationView {
                // Affichage sommaire de toutes les entrées
                if searchTitle == "Command"{
                    ScrollView(Axis.Set.vertical, showsIndicators: false) {
                        Text("Search Result")
                    }
                }
                if searchTitle == "Services"{
                    ZStack{
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack{
                                    ForEach(fetchModel.GetCategories(), id: \.self) { index in
                                        VStack(alignment: .center, spacing: 20) {
                                            AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(index)") , content: { image in
                                                image.resizable().scaledToFit()
                                            }, placeholder: {
                                                ProgressView()
                                            })
                                        }.frame(width: 100 , height: 100).background(GetColor(value: index)).clipShape(Capsule()).animation(.spring())
                                            .onTapGesture {
                                                withAnimation (.spring()) {
                                                    
                                                    selectedCategory = index
                                                    
                                                }
                                                
                                            }
                                    }
                                    
                                }
                                
                            }.padding(.vertical)
                            
                            ScrollView{
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: HorizontalAlignment.center, spacing: 30, pinnedViews: [.sectionHeaders, .sectionFooters]) {
                                    Section {
                                        ForEach(fetchModel.getServices(category: selectedCategory), id: \.self) { index in
                                            ZStack(alignment:Alignment.bottom){
                                                
                                                VStack(alignment:.leading){
                                                    Spacer()
                                                
                                                    Text(index.NAME_SERVICE).font(.title2).bold()
                                                    Text(index.services_quantity).font(.caption2).foregroundColor(.secondary)
                                                    Text(index.COST_SERVICE.formatted(.currency(code: "EUR"))).bold()
                                                }.scaledToFill()
                                   
                                            }
                                            .frame(width: 160, height:200)
                                                
                                            .background(RadialGradient(colors: [.blue,.blue.opacity(0)], center: SwiftUI.UnitPoint.center, startRadius: 10, endRadius: 50))
                                                
                                            .background(.ultraThinMaterial)
                                                
                                            .clipShape(RoundedRectangle(cornerRadius: 40))
                                                
                                            .onTapGesture(perform: {
                                                    
                                                    if suppressMode{
                                                        Task{
                                                            await fetchModel.DeleteService(service: selectedService)
                                                            
                                                        }
                                                        //fetchModel.fetchSewing()
                                                    }
                                                    else{
                                                        Task{
                                                            selectedService = index
                                                        }
                                                        withAnimation {
                                                            activeService = true
                                                        }
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                })
                                                .overlay {
                                                    AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(index.NAME_SERVICE)") , content: { image in
                                                        image.resizable().scaledToFit().offset(x: 0, y: -20).zIndex(1)
                                                            .matchedGeometryEffect(id: index.NAME_SERVICE, in: namespace)
                                                    }, placeholder: {
                                                        ProgressView()
                                                    }).offset(x:0 , y:suppressMode ? 0 : -25)
                                                        .animation(.SuppressAnimation(), value: suppressMode)
                                        
                                                }
                                        }
                                    } header: {
                                        if selectedCategory.isEmpty==false{
                                            HStack{
                                                Spacer()
                                                Button {
                                                        withAnimation{
                                                            suppressMode.toggle()
                                                        }
                                                    
                                                    
                                                } label: {
                                                    Image(systemName: "trash.circle.fill").resizable().frame(width: 50, height: 50, alignment: SwiftUI.Alignment.center)
                                                }.padding().tint(suppressMode ? .blue : .red)
                                        
                                            }
                                        }
                                    } footer: {
                                        Button {
                                            withAnimation {
                                                showAddView.toggle()
                                            }
                                        } label: {
                                            HStack{
                                                Image(systemName:"plus.circle.fill").resizable().frame(width: 50, height: 50).tint(.secondary)
                                                Text("Ajouter").foregroundColor(.primary).padding(.vertical)
                                            }.background(.ultraThinMaterial).clipShape(Capsule()).padding(.bottom)
                                        }
                                    }
                                }.padding().shadow(radius: 10)
                            }
                            }
                    }
                
                }
                if searchTitle == "Utilisateur"{
                    
                    if showDetailUserView{
                        UserDetailView(userToShow: userViewed).zIndex(5)
                    }else{
                        VStack{
                            List{
                                Section{
                                    ForEach(fetchModel.users, id: \.self){ user in
                                        HStack{
                                            AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(user.NAME_USER)") , content: { image in
                                                image.resizable().scaledToFill()
                                            }, placeholder: {
                                                ProgressView()
                                            })
                                            .frame(width: 50, height: 50).foregroundColor(.gray)
                                            Divider()
                                            VStack{
                                                HStack{
                                                    Text(user.NAME_USER).font(.title2).bold()
                                                    Text(user.SURNAME_USER).font(.title3)
                                                    Spacer()
                                                }
                                                HStack{
                                                    Text("#\(user.ID_USER.formatted())").font(.caption).foregroundColor(.secondary)
                                                    Spacer()
                                                }
                                                
                                            }
                                            Spacer()
                                        }
                                        .onTapGesture(perform: {
                                            self.userViewed = user
                                            withAnimation(.spring()) {
                                                showDetailUserView.toggle()
                                            }
                                        })

                                        //Swipe actions
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button {
                                                
                                            } label: {
                                                Image(systemName: "xmark.bin")
                                            }.tint(.red)
                                        }
                                    }
                                } header:{
                                    //Zone de recherche ===========================================================================================
                                    
                                    VStack{
                                        HStack{
                                            TextField(text: $searchText) {
                                                Text("Search in \(searchTitle)").font(Font.system(size: 30, weight: .light, design: Font.Design.rounded))
                                                    .padding().scaledToFill()
                                            }
                                            .textInputAutocapitalization(.never)
                                            .disableAutocorrection(true)
                                                .font(Font.system(size: 30, weight: .light, design: Font.Design.rounded))
                                                .clipShape(Capsule())
                                                .padding(.leading)
                                            //Search Button
                                            Button {
                                                
                                            } label: {
                                                Image(systemName: "magnifyingglass").scaledToFill()
                                            }.padding().background(.blue).clipShape(Circle()).foregroundColor(.white)
                                        }
                                            
                                    }.background().clipShape(Capsule())
                                    //Resultats de recherches. La fonction est locale recherche les noms
                                    
                                        if fetchModel.SortUsers(a: searchText).count != 0{
                                            withAnimation {
                                                Section{
                                                    ForEach (fetchModel.SortUsers(a: searchText), id: \.self){ index in
                                                            HStack{
                                                                AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(index.NAME_USER)") , content: { image in
                                                                    image.resizable().scaledToFill()
                                                                }, placeholder: {
                                                                    ProgressView()
                                                                })
                                                                .frame(width: 50, height: 50).foregroundColor(.gray)
                                                                Divider()
                                                                VStack{
                                                                    HStack{
                                                                        Text(index.NAME_USER).font(.title2).bold()
                                                                        Text(index.SURNAME_USER).font(.title3)
                                                                        Spacer()
                                                                    }
                                                                    HStack{
                                                                        Text("#\(index.ID_USER.formatted())").font(.caption)
                                                                        Spacer()
                                                                    }
                                                                    
                                                                }
                                                                
                                                                
                                                                Spacer()
                                                            }
                                                    }
                                                } header: {
                                                    Text("Resultats de recherche")
                                                }.transition(.slide)
                                            }
                                            
                                        }
                                            
                                       Text("Tous les utilisateurs")
                                    }
                            
                                
                            }
                            .background(.ultraThinMaterial)
                            .cornerRadius(40)
                            .padding(.top)
                        }
                        .background(.red)
                        
                    }
                    
               }
               
            }
            
            ZStack{
                VStack{
                    // Header
                    /*
                    VStack{
                        Text("\(searchTitle)").font(.largeTitle).bold().padding([.leading,.top]).frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.leading).matchedGeometryEffect(id: "titre", in: namespace)
                        Text("Configuaration des utilisateurs et des comptes").font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.leading).padding(.horizontal).matchedGeometryEffect(id: "sousTitre", in: namespace)
                        
                    }
                    .matchedGeometryEffect(id: "head", in: namespace)
                    */
                            
                    //Menu avancés =======================================================================================================
                        //Affichage de la page d'ajout des utilisateurs
                    if showAddView{
                        AddServiceView(
                                       category: selectedCategory,
                                       showThisView: $showAddView)
                    }
                        //Affichage d'ajout de coupons
                    if showAddCoupon{
                        AlertView(showAlert: $showAddCoupon).transition(.move(edge: .top))
                    }
                }
                .overlay(alignment: Alignment.topTrailing) {
                    Button {
                        withAnimation(.spring()) {
                            //currentPage.toggle()
                            //homePage.toggle()
                        }
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill").resizable().frame(width: 40, height: 40, alignment: Alignment.center)
                    }.padding(40)
                }
                
                
                // Vue de modification Service
                if activeService{
                    VStack(alignment:.center){
                        HStack{
                            Image(systemName:"chevron.left").resizable().padding().frame(width: 50, height: 50)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        activeService = false
                                    }
                                    
                                }
                            Spacer()
                            Image(systemName:"trash").resizable().padding().frame(width: 50, height: 50).onTapGesture {
                                Task{
                                    await fetchModel.DeleteService(service: selectedService)
                                    activeService = false
                                    //fetchModel.fetchSewing()
                                }
                                
                            }
                        }.padding()
                        
                        AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(selectedService.NAME_SERVICE)") , content: { image in
                            image.resizable().scaledToFit().matchedGeometryEffect(id: selectedService.NAME_SERVICE, in: namespace)
                        }, placeholder: {
                            ProgressView().scaledToFit().matchedGeometryEffect(id: selectedService.NAME_SERVICE, in: namespace)
                        })
                        // Informations sur l'élément. Le tout est directement modifiable
                        
                        Text(selectedService.NAME_SERVICE).font(.title).bold().padding(.horizontal)
                        Text(selectedService.services_quantity).font(.caption).foregroundColor(.secondary).padding(.horizontal)
                        
                        HStack{
                            VStack{
                                Text("Delai de Livraison")
                                HStack{
                                    Image(systemName:"timer")
                                    Text(selectedService.SIZE_SERVICE.formatted() + " Jours")
                                }
                            }
                            
                        }.padding(20)
                        
                       
                        VStack{
                            Text("Prix").frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.center)
                           /// TextField(Decimal(string:selectedService.COST_SERVICE)!.formatted(.currency(code: "EUR")), value: $selectedService.COST_SERVICE, format: .currency(code:"EUR"))
                                .font(.title2)
                        }.frame(width: 200, height: 200, alignment: SwiftUI.Alignment.center)
                       
                            
                        Spacer()
                    }
                    .background(.regularMaterial)
                    .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height, alignment: SwiftUI.Alignment.center)
                    .zIndex(500)
                }
            }
            .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height, alignment: SwiftUI.Alignment.center)
            }
            .onAppear {
                fetchModel.fetchCommands()
                //fetchModel.fetchSewing()
                fetchModel.fetchUsers()
                //fetchModel.FetchUserHasCommmands()
                fetchModel.FetchServicesHasCommmands()
                fetchModel.fetchCoupons()
                    
                withAnimation(.spring()) {
                   // homePage = false
                }
            }
            .onChange(of: FetchModels().services) { V in
                Task{
                    await userData.FetchServices()
                }
                
            }
        }
    
    func GetColor(value:String) -> Material{
        if value == selectedCategory{
            return Material.ultraThickMaterial
        }
        
        return Material.ultraThinMaterial
    }
    
    //Fonction qui change l'etat des newsletter de int en Bool
    func NewsLetterConvertter(a:Int) -> Bool{
        @State var result:Bool = false
        if a == 0{
            result = false
        }else{
            result = true
        }
        return result
    }
}
*/

