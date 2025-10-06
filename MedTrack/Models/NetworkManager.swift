//
//  NetworkManager.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.fda.gov/drug"
    
    // MARK: - Drug Information
    
    func searchDrugInfo(drugName: String, completion: @escaping (Result<DrugInfo, Error>) -> Void) {
        let encodedName = drugName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drugName
        let url = "\(baseURL)/label.json?search=openfda.brand_name:\(encodedName)&limit=1"
        
        AF.request(url).responseDecodable(of: FDAResponse.self) { response in
            switch response.result {
            case .success(let fdaResponse):
                if let firstResult = fdaResponse.results.first {
                    let drugInfo = DrugInfo(from: firstResult)
                    completion(.success(drugInfo))
                } else {
                    // No results found - return custom error
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
    
    // MARK: - Drug Interactions
    
    func checkDrugInteractions(drugs: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        guard !drugs.isEmpty else {
            completion(.success([]))
            return
        }
        
        // Query FDA API for the first drug's interactions
        let encodedName = drugs[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drugs[0]
        let url = "\(baseURL)/label.json?search=openfda.brand_name:\(encodedName)&limit=1"
        
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

