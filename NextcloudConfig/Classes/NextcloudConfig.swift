//
//  NextcloudConfig.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation
import AuthenticationServices

/// Class providing nextcloud configuration options.
public class NextcloudConfig: Any {

    let baseURL: URL
    let client: APIClient

    /// Initializer for the nextcloud config class.
    ///
    /// - parameters:
    ///   - baseURL: The url of the nextcloud server to configure for.
    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.client = APIClient(baseURL: baseURL)
    }

    /// A function to create an authentication session with nextcloud.
    /// This wraps the nextcloud [api](https://docs.nextcloud.com/server/latest/developer_manual/client_apis/LoginFlow/index.html#login-flow-v2) for login
    ///
    /// See the following code as an example of the usage:
    ///
    ///     webAuthSession = config.loginSession { urlOrNil, errorOrNil in
    ///         if let error = errorOrNil {
    ///             print(error.localizedDescription)
    ///             return
    ///         }
    ///         guard let url = urlOrNil else {
    ///             print("Failure, no error or URL")
    ///             return
    ///         }
    ///         UIApplication.shared.open(url, options: [:], completionHandler: nil)
    ///     }
    ///     _ = webAuthSession.start()
    /// The returned class suffers from the bug described here: [ajkueterman.com/handle-ios-aswebauthenticationsession-bug](https://ajkueterman.com/ios/swift/authenticationservices/handle-ios-aswebauthenticationsession-bug/) so it needs to be a class variable to be used.
    ///
    /// - SeeAlso: [documentation](https://docs.nextcloud.com/server/16/developer_manual/client_apis/LoginFlow/index.html#opening-the-webview)
    /// - Requires: iOS 11 and higher
    /// - parameters:
    ///   - completionHandler: A handler that is called at the end of authentication. Has an URL? and Error? parameter
    /// - returns: An authentication session to use, this is a wrapper of ASWebAuthenticationSession.
    @available(iOS 11, *)
    public func loginSession(completionHandler: @escaping (Result<AuthenticationSession, LoginError>) -> Void) {
        self.post(path: "index.php/login/v2", type: LoginResponse.self, data: nil) { result in
            switch result {
            case .success(let loginData):
                let session = AuthenticationSession(url: URL(string: loginData.login)!,
                                      callbackURLScheme: "nc://login/") { url, error in
                                        if let _ = error {
                                            completionHandler(.failure(.invalidLogin))
                                            return
                                        }
                                        
                }
                completionHandler(.success(session))
            case .failure(_):
                completionHandler(.failure(.v2NotAvailable))
            }
        }
    }

    /// A function to request data from an open nextcloud webservice.
    ///
    /// See the following code as an example of the usage:
    ///
    ///     config?.fetch(path: "ocs/v1.php/cloud/capabilities", type: WebserviceResponse<CapabilitiesResponse>.self) { result in
    ///         var name: String = "unknown"
    ///         switch result {
    ///         case .success(let fetchedConfig):
    ///             guard let theming = fetchedConfig.ocs.data?.capabilities?.theming else {
    ///                 return
    ///             }
    ///             name = theming.name
    ///         case .failure(let error):
    ///             text = error.localizedDescription
    ///         }
    ///         print("nextcloud server name: \(name)")
    ///     }
    ///
    /// - seealso: `CapabilitiesResponse`, the mapped response within the standard nextcloud wrappers.
    /// - seealso: `WebserviceResponse`, the mapped response standard nextcloud wrappers.
    ///
    /// - parameters:
    ///   - path: The api path to do the request to
    ///   - type: The class to expect as a response
    ///   - completionHandler: A closure that is executed at the end of the call. Has a T and NextcloudError parameter
    public func fetch<T: Codable>(path: String, type: T.Type, completionHandler: @escaping (Result<T, NextcloudError>) -> Void) {
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
            case .failure(let error):
                print("Error perform network request")
                completionHandler(.failure(error))
                return
            }
        }
    }
    
    

    /// A function to post data to an open nextcloud webservice.
    ///
    /// See the following code as an example of the usage:
    ///
    ///     config?.fetch(path: "ocs/v1.php/cloud/capabilities", type: WebserviceResponse<CapabilitiesResponse>.self) { result in
    ///         var name: String = "unknown"
    ///         switch result {
    ///         case .success(let fetchedConfig):
    ///             guard let theming = fetchedConfig.ocs.data?.capabilities?.theming else {
    ///                 return
    ///             }
    ///             name = theming.name
    ///         case .failure(let error):
    ///             text = error.localizedDescription
    ///         }
    ///         print("nextcloud server name: \(name)")
    ///     }
    ///
    /// - seealso: `CapabilitiesResponse`, the mapped response within the standard nextcloud wrappers.
    /// - seealso: `WebserviceResponse`, the mapped response standard nextcloud wrappers.
    ///
    /// - parameters:
    ///   - path: The api path to do the request to
    ///   - type: The class to expect as a response
    ///   - completionHandler: A closure that is executed at the end of the call. Has a T and NextcloudError parameter
    public func post<T: Codable>(path: String, type: T.Type, data: String?, completionHandler: @escaping (Result<T, NextcloudError>) -> Void) {
        let request = APIRequest(method: .post, path: path, body: data)
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
            case .failure(let error):
                print("Error perform network request")
                completionHandler(.failure(error))
                return
            }
        }
    }
}

/// A list of possible errors that the webservice can return.
///
/// Explanation:
/// - **badURL**: An invalid URL was passed to a function.
/// - **emptyResponse**: The request was made but the server didn't return any data.
/// - **invalidResponse**: The request was made but the server didn't return valid return data.
/// - **decodeError**: The request was made but the server didn't return data that could be decoded.
/// - **wrongStatus**: The request was made but the server returned an invalid status.
/// - **networkError**: The request was not made due to network issues.
public enum NextcloudError: Error {
    case badURL
    case emptyResponse
    case invalidResponse
    case decodeError
    case wrongStatus
    case networkError
}

public enum LoginError: Error {
    case invalidLogin
    case v2NotAvailable
}
