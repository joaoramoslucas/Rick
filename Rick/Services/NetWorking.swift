//  request.swift
//
//
//  Created by Gustavo Fidencio on 18/03/24.
//

import Foundation
import Alamofire

class NetworkManager {

    func request<T: Codable>(
        _ endpoint: String,
        method: Alamofire.HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {

        let apiUrl = "\(Routes.BASEURL.rawValue)\(endpoint)"

        let allHeaders = headers ?? [:]

        let request = AF.request(
            apiUrl,
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: HTTPHeaders(allHeaders)
        )

        request.validate(statusCode: 200..<300)

//        print("(apiUrl) (method) (String(describing: parameters)) (allHeaders)")

        request.responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                if let urlError = error.underlyingError as? URLError, urlError.code == .timedOut {
                    completion(.failure(.serverError(408)))
                } else if let urlError = error.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                    completion(.failure(.serverError(0)))
                } else if let afError = error as AFError?, case .responseValidationFailed(reason: .unacceptableStatusCode(let code)) = afError {
                    completion(.failure(.serverError(code)))
                } else {
                    completion(.failure(.networkError(error)))
                }
            }
        }
    }
}
