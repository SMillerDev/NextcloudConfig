//
//  NextcloudConfig.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation

public class NextcloudConfig: Any {

    let baseURL: URL
    let client: APIClient
    public var config: Config? = nil

    public init(baseURL: URL, sessionConfig: URLSessionConfiguration = URLSessionConfiguration()) {
        self.baseURL = baseURL
        self.client = APIClient(baseURL: baseURL, sessionConfig: sessionConfig)
    }

    public func fetch() {
        let request = APIRequest(method: .get, path: "ocs/v1.php/cloud/capabilities")

        client.perform(request) { (result) in
            switch result {
            case .success(let response):
                guard let body = response.body else {
                    debugPrint(response.body ?? "NO_BODY")
                    return
                }
                guard let string = String(data: body, encoding: .utf8) else {
                    debugPrint(String(data: body, encoding: .utf8) ?? "NO_STRING")
                    return
                }
                debugPrint(string)
                debugPrint(response.request?.allHTTPHeaderFields ?? "NONE")

                if response.statusCode > 299 || response.statusCode < 200 {
                    print("Query failed")
                    return
                }
                if let response = try? response.decode(to: Config.self) {
                    let config = response.body
                    print("Received config: \(config.data?.version?.string ?? "")")
                    self.config = config
                    return
                } else {
                    print("Failed to decode response")
                    return
                }
            case .failure:
                print("Error perform network request")
                return
            }
        }
    }
}
