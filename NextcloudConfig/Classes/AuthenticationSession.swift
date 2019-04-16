//
//  AuthenticationSession.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation
import AuthenticationServices
import SafariServices

public protocol AuthenticationSessionProtocol {
    init(url URL: URL,
         callbackURLScheme: String?,
         completionHandler: @escaping (URL?, Error?) -> Void)

    func start() -> Bool
    func cancel()
}

@available(iOS 11.0, *)
extension SFAuthenticationSession: AuthenticationSessionProtocol {
}

@available(iOS 12.0, *)
extension ASWebAuthenticationSession: AuthenticationSessionProtocol {
}

open class AuthenticationSession: AuthenticationSessionProtocol {

    private let innerAuthenticationSession: AuthenticationSessionProtocol!

    required public init(url URL: URL,
                  callbackURLScheme: String?,
                  completionHandler: @escaping (URL?, Error?) -> Void) {

        if #available(iOS 12, *) {
            innerAuthenticationSession = ASWebAuthenticationSession(url: URL,
                                                                    callbackURLScheme: callbackURLScheme,
                                                                    completionHandler: completionHandler)
        } else if #available(iOS 11, *) {
            innerAuthenticationSession = SFAuthenticationSession(url: URL,
                                                                 callbackURLScheme: callbackURLScheme,
                                                                 completionHandler: completionHandler)
        } else {
            innerAuthenticationSession = nil
        }
    }

    public func start() -> Bool {
        return innerAuthenticationSession.start()
    }

    public func cancel() {
        innerAuthenticationSession.cancel()
    }
}
