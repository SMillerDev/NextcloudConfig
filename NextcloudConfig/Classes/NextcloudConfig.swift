//
//  NextcloudConfig.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation
import AuthenticationServices

public class NextcloudConfig: Any {

    let baseURL: URL
    let client: APIClient

    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.client = APIClient(baseURL: baseURL)
    }

    public func loginSession(completionHandler: @escaping (URL?, Error?) -> Void) -> AuthenticationSessionProtocol {
        return AuthenticationSession(url: baseURL.appendingPathExtension("/index.php/login/flow"),
                                               callbackURLScheme: "nc://login/", completionHandler: completionHandler)
    }

    public func fetch<T: Codable>(path: String, type: T.Type, completionHandler: @escaping (Result<T, NextcloudError>) -> Void){
        let request = APIRequest(method: .get, path: path)
        client.perform(request) { (result) in
            switch result {
            case .success(let response):
                if response.statusCode > 299 || response.statusCode < 200 {
                    print("Query failed")
                    completionHandler(.failure(.wrongStatus))
                    return
                }

                guard let data = response.body else {
                    completionHandler(.failure(.emptyResponse))
                    return
                }

                do {
                    let decodedJSON = try JSONDecoder().decode(T.self, from: data)
                    completionHandler(.success(decodedJSON))
                    return
                } catch {
                    print(error.localizedDescription)
                    completionHandler(.failure(.decodeError))
                    return
                }
            case .failure:
                print("Error perform network request")
                completionHandler(.failure(.networkError))
                return
            }
        }
    }
}

public enum NextcloudError: Error {
    case badURL
    case emptyResponse
    case invalidResponse
    case decodeError
    case wrongStatus
    case networkError
}
