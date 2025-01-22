//
//  Character.swift
//  Rick
//
//  Created by Jao on 21/08/24.
//

import Foundation

struct Character: Codable, Identifiable {
    var id: Int
    var name: String
    var status: String?
    var specie: String?
    var type: String?
    var gender: String
    var origin: OriginConfig
    var image: String?
    var url: String
    var created: String
    var episode: [String]
}
