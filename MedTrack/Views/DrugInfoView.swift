//
//  DrugInfoView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

// View to fetch and display detailed drug information.
struct DrugInfoView: View {
    let drugName: String                     // Name of drug to query info for
    
    @State private var drugInfo: DrugInfo?  // Holds fetched drug info details
    @State private var isLoading = false    // Loading indicator flag
    @State private var errorMessage: String? // Stores error message on failure
    @Environment(\.dismiss) var dismiss     // Dismiss action for modal view
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    // Show loading spinner while fetching data
                    ProgressView("Loading drug information...")
                } else if let error = errorMessage {
                    // Show error UI with retry button
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Unable to Load Information")
                            .font(.headline)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            loadDrugInfo()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if let info = drugInfo {
                    // Display detailed drug info in scrollable sections
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            InfoSection(title: "Brand Name", content: info.brandName)
                            InfoSection(title: "Generic Name", content: info.genericName)
                            InfoSection(title: "Manufacturer", content: info.manufacturer)
                            InfoSection(title: "Purpose", content: info.purpose)
                            InfoSection(title: "Usage", content: info.usage)
                            InfoSection(title: "Warnings", content: info.warnings, isWarning: true)
                            InfoSection(title: "Dosage", content: info.dosage)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Drug Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()  // Close view
                    }
                }
            }
        }
        .onAppear {
            loadDrugInfo()   // Trigger info fetch on appear
        }
    }
    
    // Fetches drug information from network and handles errors.
    private func loadDrugInfo() {
        isLoading = true
        errorMessage = nil
        
        NetworkManager.shared.searchDrugInfo(drugName: drugName) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let info):
                    drugInfo = info
                case .failure(let error):
                    // Provide user-friendly error messages based on error type
                    if error is DecodingError {
                        errorMessage = "No information found for '\(drugName)'. Try a different medication name."
                    } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        errorMessage = "No internet connection. Please check your network."
                    } else {
                        errorMessage = "Unable to load drug information. Please try again."
                    }
                }
            }
        }
    }
}

// Subview representing a titled info section with optional warning style.
struct InfoSection: View {
    let title: String
    let content: String
    var isWarning: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: isWarning ? "exclamationmark.triangle.fill" : "info.circle")
                .font(.headline)
                .foregroundColor(isWarning ? .red : .blue)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isWarning ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
