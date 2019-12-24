//
//  QAObject.swift
//  CoreMLBert
//
//  Created by han guang on 2019/12/24.
//  Copyright © 2019 Hugging Face. All rights reserved.
//

import Foundation

struct QAObject: Decodable {
    
    static func load(from json: String) -> QAObject {
        let url = Bundle.main.url(forResource: json, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        let object = try! decoder.decode(QAObject.self, from: data)
        return object
    }
    
    let titles: [[String]]
    let contents: [[String]]
    let questions: [[String]]
}
