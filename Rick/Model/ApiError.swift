//
//  ApiError.swift
//  Rick
//
//  Created by Jao on 21/08/24.
//

import Foundation

enum ApiError: Error {
    case networkError(Error)
    case decodingError
    case serverError(Int)
    case unknown
}
