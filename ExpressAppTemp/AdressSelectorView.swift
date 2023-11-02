//
//  AdressSelectorView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 25/10/2023.
//

import SwiftUI
import MapKit

struct AdressSelectorView: View {
    @EnvironmentObject var utilisateur:Utilisateur
    @StateObject var locationManager:LocationManager =  LocationManager()
    @Environment(\.colorScheme) var colorScheme
    @Binding var show:Bool
    var body: some View {
        GeometryReader {
            let size:CGSize = $0.size
            #warning("To Do")
            //MARK: Map as background
            MapviewSelection()
                .ignoresSafeArea()
                .environmentObject(locationManager)
                .overlay(alignment: Alignment.center) {
                    let color = colorScheme == .dark ? Color.black : Color.white
                    //var opacityLev = utilisateur.this.adress.isEmpty ? 0.8 : 0
                    VStack{}
                    
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                        .background(LinearGradient(colors: [
                            color.opacity(1),
                            color.opacity(utilisateur.this.adress.isEmpty ? 0.8 : 0),
                            color.opacity(0)
                        ], startPoint: .bottom, endPoint: .center))
                }
            
            
            VStack{
                //MARK: Text to specify that what we need address for
                ZStack{
                    VStack{
                        Image(systemName: "location")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundStyle(.gray)
                        Text("Nous avons besoin de votre adresse pour la récupération et la livraison du linge")
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.3)
                            .font(.custom("ubuntu", size: 15))
                    }
                    .frame(maxWidth: .infinity)
                    .offset(x:locationManager.fetchedPlaces == nil ? 0 : 500)
                    
                    //ELSE:
                    //MARK: Print possible address
                    if let places = locationManager.fetchedPlaces, !places.isEmpty{
                        ScrollView(showsIndicators: false, content: {
                            VStack{
                                ForEach(places,id: \.self) { place in
                                    Button(action: {
                                        //MARK: Set Map region
                                        locationManager.mapView.region = .init(center: CLLocationCoordinate2D(latitude: place.location?.coordinate.latitude ?? 0.0, longitude: place.location?.coordinate.longitude ?? 0.0), latitudinalMeters: 300, longitudinalMeters: 300)
                                        locationManager.setPin(CLLocationCoordinate2D(latitude: place.location?.coordinate.latitude ?? 0.0, longitude: place.location!.coordinate.longitude ))
                                        //MARK: Set datas to current user
                                        utilisateur.this.adress = "\(place.name!) \(place.postalCode!) \(place.locality!)"
                                        utilisateur.this.province = place.administrativeArea!
                                        utilisateur.this.loc_lat = Float((place.location?.coordinate.latitude)!)
                                        utilisateur.this.loc_lon = Float((place.location?.coordinate.longitude)!)
                                    }, label: {
                                        VStack{
                                            Text(place.name ?? "")
                                            Text("\(place.postalCode ?? "") \(place.locality ?? "") - \(place.administrativeArea ?? "")")
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment:.center)
                                    })
                                   
                                }
                            }
                            .frame(height: 200,alignment: .bottom)
                            
                        })
                        .frame(height:200,alignment: .bottom)
                    }
                }
                
                if utilisateur.this.adress.isEmpty{
                    TextField("Entrez votre adresse", text: $locationManager.searchText)
                        .padding()
                        .background(.bar)
                }
                else{
                    //MARK: Address is correct for the user or not.
                    VStack{
                        Text("Cette adresse est-elle correcte ?")
                        Button(action: {
                            //If this user, we can update this
                            Task{
                               show = await !utilisateur.this.update()
                            
                            }
                        }, label: {
                            Text("Oui, c'est correct")
                                .padding()
                                .frame(maxWidth: .infinity)
                        })
                        .buttonBorderShape(.roundedRectangle(radius: 10))
                        .buttonStyle(.borderedProminent)
                        
                        // If not, restart the process
                        Button {
                            withAnimation {
                                utilisateur.this.adress = ""
                                locationManager.searchText = ""
                                locationManager.fetchedPlaces = nil
                            }
                            
                        } label: {
                            Text("Non, je veux recommencer")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .underline()
                        }
                        .padding(.top)

                    }
                    .padding()
                    .background(.bar)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                    
                
            }
            .padding()
            .frame(maxHeight: .infinity,alignment: .bottom)
            
        }
        .frame(alignment: .bottom)
    }
}

#Preview {
    AdressSelectorView(show: .constant(true))
        .environmentObject(Utilisateur())
}

//MARK: Mapview Live selection
struct MapviewSelection:View {
    @EnvironmentObject var locationManager:LocationManager
    var body: some View{
        ZStack{
            MapviewHelper()
                .environmentObject(locationManager)
        }
    }
}

//MARK: UIKIT MapView
struct MapviewHelper:UIViewRepresentable{
    @EnvironmentObject var locationManager:LocationManager
    func makeUIView(context: Context) -> MKMapView {
        return locationManager.mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
}