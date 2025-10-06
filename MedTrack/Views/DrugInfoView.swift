//
//  DrugInfoView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//


import SwiftUI

struct DrugInfoView: View {
    let drugName: String
    
    @State private var drugInfo: DrugInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading drug information...")
                } else if let error = errorMessage {
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
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadDrugInfo()
        }
    }
    
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
                    // Better error handling
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

