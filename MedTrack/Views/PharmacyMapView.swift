//
//  PharmacyMapView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI
import MapKit
import CoreLocation

// Map view showing nearby pharmacies with annotations and details.
import SwiftUI
import MapKit

struct PharmacyMapView: View {
    @StateObject private var viewModel = PharmacyViewModel()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(viewModel.pharmacies) { pharmacy in
                    Annotation(pharmacy.name, coordinate: pharmacy.coordinate) {
                        VStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 30, height: 30)
                                )
                            Text(pharmacy.name)
                                .font(.caption)
                                .padding(4)
                                .background(.blue)
                                .cornerRadius(4)
                        }
                        .onTapGesture {
                            viewModel.selectedPharmacy = pharmacy
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .edgesIgnoringSafeArea(.all)
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView("Searching for pharmacies...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text(errorMessage)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    Spacer()
                }
            }
            
            // Pharmacy count
            VStack {
                Text("Found \(viewModel.pharmacies.count) pharmacies")
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 50)
                
                Spacer()
                
                if let pharmacy = viewModel.selectedPharmacy {
                    PharmacyInfoCard(pharmacy: pharmacy) {
                        viewModel.openInMaps(pharmacy: pharmacy)
                    }
                    .padding()
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .onAppear {
            print("PharmacyMapView appeared")
            viewModel.searchNearbyPharmacies()
        }
        .onChange(of: viewModel.region) { oldValue, newValue in
            position = .region(newValue)
        }
        .navigationTitle("Find Pharmacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

// Displays details of selected pharmacy with action button.
struct PharmacyInfoCard: View {
    let pharmacy: PharmacyAnnotation
    let onDirectionsTapped: () -> Void     // Action callback for directions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(pharmacy.name)
                .font(.headline)
            
            Text(pharmacy.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let distance = pharmacy.distance {
                Text(String(format: "%.1f km away", distance / 1000))
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Button(action: onDirectionsTapped) {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
    }
}
