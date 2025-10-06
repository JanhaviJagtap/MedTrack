//
//  PharmacyViewModel.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI
import MapKit
import CoreLocation

class PharmacyViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var pharmacies: [PharmacyAnnotation] = []
    @Published var selectedPharmacy: PharmacyAnnotation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    private let fixedLocation = CLLocation(latitude: -33.8688, longitude: 151.2093)
    
    func searchNearbyPharmacies() {
        isLoading = true
        errorMessage = nil
        
        print("Starting pharmacy search near Sydney: \(fixedLocation.coordinate.latitude), \(fixedLocation.coordinate.longitude)")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "pharmacy"
        request.region = MKCoordinateRegion(
            center: fixedLocation.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Search failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let response = response else {
                print("No response from search")
                DispatchQueue.main.async {
                    self.errorMessage = "No response from search"
                }
                return
            }
            
            print("Received \(response.mapItems.count) results")
            
            DispatchQueue.main.async {
                self.pharmacies = response.mapItems.map { item in
                    let pharmacyLocation = CLLocation(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )
                    let distance = self.fixedLocation.distance(from: pharmacyLocation)
                    
                    print("Found: \(item.name ?? "Unknown") at \(item.placemark.coordinate)")
                    
                    return PharmacyAnnotation(
                        name: item.name ?? "Pharmacy",
                        address: item.placemark.title ?? "",
                        coordinate: item.placemark.coordinate,
                        distance: distance,
                        mapItem: item
                    )
                }
                
                print("Total pharmacies added: \(self.pharmacies.count)")
                
                if self.pharmacies.isEmpty {
                    self.errorMessage = "No pharmacies found nearby"
                }
            }
        }
    }
    
    func openInMaps(pharmacy: PharmacyAnnotation) {
        pharmacy.mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
