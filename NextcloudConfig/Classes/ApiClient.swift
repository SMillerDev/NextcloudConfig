//
//  ApiClient.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation

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

struct HTTPHeader {
    let field: String
    let value: String
}

class APIRequest {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?

    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
    }

    init<Body: Encodable>(method: HTTPMethod, path: String, body: Body) throws {
        self.method = method
        self.path = path
        self.body = try JSONEncoder().encode(body)
    }
}

public struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
    let request: URLRequest?
}

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailure
}

enum APIResult<Body> {
    case success(APIResponse<Body>)
    case failure(APIError)
}

public struct WebserviceResponse<T: Codable>: Codable {
    public let ocs: WebserviceOcsResponse<T>
    public func get() -> T? {
        return ocs.data
    }
}

public struct WebserviceOcsResponse<T: Codable>: Codable {
    public let data: T?
    public let meta: WebserviceMeta
}

public struct WebserviceMeta: Codable {
    public let status: String
    public let statuscode: Int
    public let message: String
    public let totalitems: String?
    public let itemsperpage: String?
}

struct APIClient {

    typealias APIClientCompletion = (Result<APIResponse<Data?>, APIError>) -> Void

    private let session: URLSession
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpCookieAcceptPolicy = .onlyFromMainDocumentDomain
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: sessionConfig)
    }

    func perform(_ request: APIRequest, _ completion: @escaping APIClientCompletion) {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        urlComponents.queryItems = request.queryItems

        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion(.failure(.invalidURL)); return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.allHTTPHeaderFields = [
            "OCS-APIRequest": "true",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept-Language": Locale.preferredLanguages.prefix(6).qualityEncoded,
            "Accept-Encoding": ["br", "gzip", "deflate"].qualityEncoded,
            "User-Agent": APIRequest.defaultUserAgent,
        ]

        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed)); return
            }
            let response = APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data, request: urlRequest)
            completion(.success(response))
        }
        task.resume()
    }
}

extension APIRequest {
    /// Returns NextCloudConfig default `User-Agent` header.
    ///
    /// See the [User-Agent header documentation](https://tools.ietf.org/html/rfc7231#section-5.5.3).
    ///
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

extension Collection where Element == String {
    var qualityEncoded: String {
        return enumerated().map { (index, encoding) in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
            }.joined(separator: ", ")
    }
}
