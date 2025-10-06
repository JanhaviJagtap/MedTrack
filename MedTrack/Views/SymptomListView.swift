//
//  SymptomView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

struct SymptomListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Symptom.date, ascending: false)],
        animation: .default)
    private var symptoms: FetchedResults<Symptom>
    
    @State private var showingAddSymptom = false
    
    var body: some View {
        NavigationView {
            List {
                if symptoms.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Symptoms Logged")
                            .font(.headline)
                        
                        Text("Track your symptoms over time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(symptoms) { symptom in
                        SymptomRow(symptom: symptom)
                    }
                    .onDelete(perform: deleteSymptoms)
                }
            }
            .navigationTitle("Symptoms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSymptom = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSymptom) {
                AddSymptomView()
            }
        }
    }
    
    private func deleteSymptoms(offsets: IndexSet) {
        withAnimation {
            offsets.map { symptoms[$0] }.forEach { symptom in
                CoreDataManager.shared.deleteSymptom(symptom)
            }
        }
    }
}

struct SymptomRow: View {
    let symptom: Symptom
    
    var severityColor: Color {
        switch symptom.severity {
        case 1...3: return .green
        case 4...6: return .orange
        case 7...10: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(severityColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(symptom.severity)")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(symptom.name ?? "Unknown")
                    .font(.headline)
                
                if let date = symptom.date {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddSymptomView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var severity = 5
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Symptom Details") {
                    TextField("Symptom Name", text: $name)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Severity: \(severity)")
                            .font(.headline)
                        
                        Slider(value: Binding(
                            get: { Double(severity) },
                            set: { severity = Int($0) }
                        ), in: 1...10, step: 1)
                        
                        HStack {
                            Text("Mild")
                                .font(.caption)
                                .foregroundColor(.green)
                            Spacer()
                            Text("Moderate")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Spacer()
                            Text("Severe")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSymptom()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveSymptom() {
        CoreDataManager.shared.addSymptom(
            name: name,
            severity: severity,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}
