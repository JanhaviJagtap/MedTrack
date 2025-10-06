//
//  NetworkManager.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import Foundation
import Alamofire

// Manages network calls to the FDA drug API.
class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.fda.gov/drug"
    
    
    
    // Searches drug information by name.
    func searchDrugInfo(drugName: String, completion: @escaping (Result<DrugInfo, Error>) -> Void) {
        let encodedName = drugName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drugName
        let url = "\(baseURL)/label.json?search=openfda.brand_name:\(encodedName)&limit=1"
        
        // Make network request and decode response
        AF.request(url).responseDecodable(of: FDAResponse.self) { response in
            switch response.result {
            case .success(let fdaResponse):
                if let firstResult = fdaResponse.results.first {
                    let drugInfo = DrugInfo(from: firstResult)
                    completion(.success(drugInfo))
                } else {
                    // No results found
                    let error = NSError(domain: "MediTrack", code: 404, userInfo: [
                        NSLocalizedDescriptionKey: "No results found"
                    ])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    
    // Checks drug interactions for a list of drugs.
    // Currently only checks first drug in the list.
    func checkDrugInteractions(drugs: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        guard !drugs.isEmpty else {
            completion(.success([])) // Empty list returns empty interactions
            return
        }
        
        let encodedName = drugs[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drugs[0]
        let url = "\(baseURL)/label.json?search=openfda.brand_name:\(encodedName)&limit=1"
        
        // Make network request and decode response
        AF.request(url).responseDecodable(of: FDAResponse.self) { response in
            switch response.result {
            case .success(let fdaResponse):
                if let firstResult = fdaResponse.results.first {
                    let interactions = firstResult.drug_interactions ?? ["No interaction data available"]
                    completion(.success(interactions))
                } else {
                    completion(.success(["No interaction data available"]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
