//
//  UserAllView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 21/03/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct UserAllView: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var utilisateur:Utilisateur
    @State var selectedUser:User = User()
    @State private var moreInfos:Bool = false
    @State var searchText:String=String.init()
    @State var modifyMode:Bool=false
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.334_900,
                                           longitude: -122.009_020),
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
    var body: some View {
        GeometryReader {
            let size = $0.size
            NavigationView {
                List(){
                    Section{
                        ForEach(utilisateur.all.sorted(by: {$0.id < $1.id}), id: \.self){ u in
                            NavigationLink {
                                UserDetailView(userToReview: u)
                            } label: {
                                HStack{
                                    VStack{
                                        HStack{
                                            Text(u.name).font(.title2).bold()
                                            Text(u.surname).font(.title3)
                                            Spacer()
                                        }
                                        HStack{
                                            Text("#\(u.id.formatted())").font(.caption).foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                    .onTapGesture {
                                       /*
                                        DispatchQueue.main.async {
                                            fetchModel.user_to_review = u
                                            selectedUser = u
                                        }*/
                                        //moreInfos.toggle()

                                    }
                                    Spacer()
                                }
                            }

                           
                            
                            

                            //Swipe actions
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role:.destructive) {
                                    
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
                                    Text("Rechercher un utilisateur").font(Font.system(size: 20, weight: .light, design: Font.Design.rounded))
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
                            
                        }
                        .shadow(radius: 10)
                        .background().clipShape(Capsule())
                        .padding(.top, 50)
                        //Resultats de recherches. La fonction est locale recherche les noms
                        
                        if !searchText.isEmpty{
                                withAnimation {
                                    Section{
                                        ForEach (utilisateur.all.sorted(by: {$0.id < $1.id}), id: \.self){ index in
                                            if(index.name.capitalized.contains(searchText)){
                                                HStack{
                                                    AsyncImage(url: URL(string: "http://\(urlServer):\(urlPort)/getimage?name=\(index.name)") , content: { image in
                                                        image.resizable().scaledToFill()
                                                    }, placeholder: {
                                                        ProgressView()
                                                    })
                                                    .frame(width: 50, height: 50).foregroundColor(.gray)
                                                    Divider()
                                                    VStack{
                                                        HStack{
                                                            Text(index.name).font(.title2).bold()
                                                            Text(index.surname).font(.title3)
                                                            Spacer()
                                                        }
                                                        HStack{
                                                            Text("#\(index.id.formatted())").font(.caption)
                                                            Spacer()
                                                        }
                                                    }
                                                    Spacer()
                                                }
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
                .edgesIgnoringSafeArea(.top)
            }
            
            //.ignoresSafeArea(.top)
            .background(.ultraThinMaterial)
            .listStyle(.inset)
            /*
            .fullScreenCover(isPresented: $moreInfos) {
                UserDetailView()
            }*/
        }
        .onAppear{
            utilisateur.fetch()
            
        }
    }
}

struct UserAllView_Previews: PreviewProvider {
    static var previews: some View {
        UserAllView().environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Utilisateur())
    }
}
