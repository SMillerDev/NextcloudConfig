//
//  ApiClient.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation

/// HTTP Method indicator
enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

/// Description of a HTTP header
struct HTTPHeader {
    let field: String
    let value: String
}

/// Nextcloud API Response.
///
/// Contains the original request for debugging purposes.
public struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
    let request: URLRequest?
}

/// Class describing a future API request
/// # Usage
/// ## Without data (GET/HEAD/DELETE/...)
///     let request = APIRequest(method: .get, path: "index/flox")
/// ## With data (POST/PATCH/PUT/...)
///     let request = APIRequest(method: .put, path: "index/flox", body: SomeEncodableClass())
class APIRequest {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?

    /// Initialize an empty request
    /// - parameters:
    ///   - method: The HTTP method to use
    ///   - path: The relative path from the baseURL
    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
        self.headers = [
            HTTPHeader(field: "OCS-APIRequest", value: "true"),
            HTTPHeader(field: "Content-Type", value: "application/json"),
            HTTPHeader(field: "Accept", value: "application/json"),
            HTTPHeader(field: "Accept-Language", value: Locale.preferredLanguages.prefix(6).qualityEncoded),
            HTTPHeader(field: "Accept-Encoding", value: ["br", "gzip", "deflate"].qualityEncoded),
            HTTPHeader(field: "User-Agent", value: APIRequest.defaultUserAgent)
        ]
    }

    /// Initialize a request with a body as JSON
    /// - parameters:
    ///   - method: The HTTP method to use
    ///   - path: The relative path from the baseURL
    ///   - body: `Encodable` The data that should be in the HTTP body
    init<Body: Encodable>(method: HTTPMethod, path: String, body: Body) {
        self.method = method
        self.path = path
        self.body = try? JSONEncoder().encode(body)
    }
}

/// An API client to make Nextcloud API requests with
struct APIClient {
    private let session: URLSession
    private let baseURL: URL

    /// Initialize a client
    /// - parameters:
    ///   - baseURL: The Nextcloud server url to configure for.
    init(baseURL: URL) {
        self.baseURL = baseURL
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpCookieAcceptPolicy = .onlyFromMainDocumentDomain
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: sessionConfig)
    }

    /// Perform an API request with all the correct headers set for nextcloud.
    ///
    /// - parameters:
    ///   - request: The API request that the client will perform
    ///   - completion: The Result of that request as a closure
    func perform(_ request: APIRequest, _ completion: @escaping (Result<APIResponse<Data?>, NextcloudError>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        urlComponents.queryItems = request.queryItems

        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion(.failure(.badURL)); return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError)); return
            }
            let response = APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data, request: urlRequest)
            completion(.success(response))
        }
        task.resume()
    }
}

/// An extension to provide a useragent to the API request class
extension APIRequest {
    /// Returns NextCloudConfig default `User-Agent` header.
    /// See the [User-Agent header documentation](https://tools.ietf.org/html/rfc7231#section-5.5.3).
    /// Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1)`
    public static let defaultUserAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild))"
        }

        return "NextcloudConfig"
    }()
}

/// Convenience method to encode collections for usage in headers
extension Collection where Element == String {

    /// Convenience option that encodes collections for usage in HTTP headers
    /// - returns: `String` HTTP encoded collection
    var qualityEncoded: String {
        return enumerated().map { (index, encoding) in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
            }.joined(separator: ", ")
    }
}
