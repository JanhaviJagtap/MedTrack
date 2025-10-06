//
//  DrugSearchView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//


import SwiftUI

struct DrugSearchView: View {
    @State private var searchText = ""
    @State private var showingDrugInfo = false
    @State private var interactions: [String] = []
    @State private var isLoading = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        animation: .default)
    private var medications: FetchedResults<Medication>
    
    var body: some View {
        VStack(spacing: 20) {
            // Search Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Search Drug Information")
                    .font(.headline)
                
                TextField("Enter medication name", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: searchDrug) {
                    Label("Search", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(searchText.count < 3)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            
            // Check Interactions
            if !medications.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Check Drug Interactions")
                        .font(.headline)
                    
                    Text("Check if your current medications interact with each other")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: checkInteractions) {
                        Label("Check Interactions", systemImage: "exclamationmark.triangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            
            // Results
            if isLoading {
                ProgressView()
            } else if !interactions.isEmpty {
                InteractionResultsView(interactions: interactions)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Drug Search")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDrugInfo) {
            DrugInfoView(drugName: searchText)
        }
    }
    
    private func searchDrug() {
        showingDrugInfo = true
    }
    
    private func checkInteractions() {
        isLoading = true
        interactions = []
        
        let drugNames = medications.compactMap { $0.name }
        
        NetworkManager.shared.checkDrugInteractions(drugs: drugNames) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let interactionList):
                    interactions = interactionList
                case .failure:
                    interactions = ["Unable to check interactions. Please try again."]
                }
            }
        }
    }
}

struct InteractionResultsView: View {
    let interactions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Interaction Results", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(interactions, id: \.self) { interaction in
                        Text("• \(interaction)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}
