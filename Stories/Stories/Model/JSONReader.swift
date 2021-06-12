//
//  JSONReader.swift
//  Stories
//
//  Created by alc on 10.06.2021.
//

import Foundation

struct JSONReader: Codable {

    func parseJSON<T:Codable>(safeData:Data)-> T?  {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: safeData)
        } catch let err{
           print("JSON parsing error:",err)
        }
        return nil
    }
    
    func readLocalJSONFile(forFile filename: String) -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: filename, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                return data
            }
        } catch {
            print("JSON reading error: \(error)")
        }
        return nil
    }
}
