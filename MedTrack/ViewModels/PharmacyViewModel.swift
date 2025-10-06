//
//  PharmacyViewModel.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI
import MapKit
import CoreLocation

// ViewModel responsible for handling pharmacy search and map region updates.
class PharmacyViewModel: NSObject, ObservableObject {
    // Current map region centered around Sydney coordinates.
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // List of nearby pharmacies as map annotations.
    @Published var pharmacies: [PharmacyAnnotation] = []
    // Currently selected pharmacy for detail display.
    @Published var selectedPharmacy: PharmacyAnnotation?
    // Flag to indicate if a search is in progress.
    @Published var isLoading = false
    // Stores any error message from a search failure.
    @Published var errorMessage: String?
    
    //Fixed location (Sydney) for search anchor.
    private let fixedLocation = CLLocation(latitude: -33.8688, longitude: 151.2093)
    
    // Initiates a search for pharmacies nearby the fixed location.
    func searchNearbyPharmacies() {
        isLoading = true
        errorMessage = nil
        
        // Create a local search request for pharmacies within 5km radius.
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
                DispatchQueue.main.async {
                    self.errorMessage = "Search failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let response = response else {
                DispatchQueue.main.async {
                    self.errorMessage = "No response from search"
                }
                return
            }
            
            // Map each result to PharmacyAnnotation including calculating distance.
            DispatchQueue.main.async {
                self.pharmacies = response.mapItems.map { item in
                    let pharmacyLocation = CLLocation(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )
                    let distance = self.fixedLocation.distance(from: pharmacyLocation)
                    
                    return PharmacyAnnotation(
                        name: item.name ?? "Pharmacy",
                        address: item.placemark.title ?? "",
                        coordinate: item.placemark.coordinate,
                        distance: distance,
                        mapItem: item
                    )
                }
                
                if self.pharmacies.isEmpty {
                    self.errorMessage = "No pharmacies found nearby"
                }
            }
        }
    }
    
    // Opens the selected pharmacy location in Apple Maps with driving directions.
    func openInMaps(pharmacy: PharmacyAnnotation) {
        pharmacy.mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
