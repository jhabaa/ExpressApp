//
//  LocationManager.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 25/10/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit
//MARK: Combine framework to watch Textfield change
import Combine

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate{
    //MARK: Properties
    @Published var mapView:MKMapView = .init()
    @Published var manager:CLLocationManager = .init()
    //MARK: Search bar text
    @Published var searchText:String = String()
    var cancellable:AnyCancellable?
    @Published var fetchedPlaces:[CLPlacemark]?
    @Published var userPosition:CLLocation?
    
    override init() {
        super.init()
        //MARK: Setting delegates
        manager.delegate = self
        mapView.delegate = self
        //MARK: Requesting location Access
        manager.requestWhenInUseAuthorization()
        //MARK: Search textfield watching
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                // Run function
                if value != ""{
                    self.fetchPlaces(value)
                }else{
                    self.fetchedPlaces = nil
                }
                
            })
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {return}
        self.userPosition = loc
    }
    //MARK: Add pin
    func setPin(_ coord:CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = "Le linge sera récupéré ici"
        mapView.addAnnotation(annotation)
    }
    func fetchPlaces(_ value:String){
        //MARK:Fetch places
        Task{
            do{
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                
                let response = try await MKLocalSearch(request: request).start()
                //We can also use Mainactor to publish in main
                await MainActor.run {
                    self.fetchedPlaces = response.mapItems.compactMap({item -> CLPlacemark? in return item.placemark})
                }
            }
            catch{
                //Handle ERROR
                
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //HANDLE ERROR
    }
    //MARK: Location Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:manager.requestLocation()
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:manager.requestLocation()
        case .restricted:manager.requestLocation()
        case .denied: handleLocationError()
            
        default:()
            
        }
    }
    func handleLocationError(){
        
    }
    
}
