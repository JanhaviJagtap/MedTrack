//
//  APIModels.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import MapKit
import CoreLocation
// Top-level FDA API response containing multiple drug labels.
struct FDAResponse: Codable {
    let results: [FDADrugLabel]
}
// Represents a single drug label entry from the FDA.
struct FDADrugLabel: Codable {
    let openfda: OpenFDA?
    let purpose: [String]?
    let indications_and_usage: [String]?
    let warnings: [String]?
    let drug_interactions: [String]?
    let dosage_and_administration: [String]?
}
// Detailed naming and manufacturer information from FDA.
struct OpenFDA: Codable {
    let brand_name: [String]?
    let generic_name: [String]?
    let manufacturer_name: [String]?
}
// Simplified drug information used by the app UI.
struct DrugInfo {
    let brandName: String
    let genericName: String
    let manufacturer: String
    let purpose: String
    let usage: String
    let warnings: String
    let dosage: String
    // Initialize from FDADrugLabel, providing default text for missing fields.
    init(from fdaLabel: FDADrugLabel) {
        self.brandName = fdaLabel.openfda?.brand_name?.first ?? "Unknown"
        self.genericName = fdaLabel.openfda?.generic_name?.first ?? "Unknown"
        self.manufacturer = fdaLabel.openfda?.manufacturer_name?.first ?? "Unknown"
        self.purpose = fdaLabel.purpose?.first ?? "No information available"
        self.usage = fdaLabel.indications_and_usage?.first ?? "No information available"
        self.warnings = fdaLabel.warnings?.first ?? "No warnings available"
        self.dosage = fdaLabel.dosage_and_administration?.first ?? "Consult your doctor"
    }
}

// Model for pharmacy annotation to display on map views.
struct PharmacyAnnotation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distance: CLLocationDistance?   // Distance from user locatio
    let mapItem: MKMapItem              // Enables map directions
}
