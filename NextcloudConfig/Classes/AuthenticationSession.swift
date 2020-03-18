//
//  AuthenticationSession.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation
import AuthenticationServices
import SafariServices

/// A class that manages sharing a one-time login between Safari and an app, which can also be used for automatic login for associated apps.
///
/// An ASWebAuthenticationSession object can be used to authenticate a user with a web service, even if the web service is run by a third party. ASWebAuthenticationSession puts the user in control of whether they want to use their existing logged-in session from Safari.
/// - note: All cookies, except session cookies, can be shared with Safari.
open class AuthenticationSession: AuthenticationSessionProtocol {

    private let innerAuthenticationSession: AuthenticationSessionProtocol!
    
    private let vc = AuthenticationSessionViewController()

    /// Returns a web authentication session object.
    ///
    /// - parameters:
    ///   - url: The initial URL pointing to the authentication webpage. Only supports URLs with http:// or https:// schemes.
    ///   - callbackURLScheme: The custom URL scheme that the app expects in the callback URL.
    ///   - completionHandler: The completion handler which is called when the session is completed successfully or canceled by user.
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
        if #available(iOS 13.0, *) {
            (innerAuthenticationSession as! ASWebAuthenticationSession).presentationContextProvider = vc
        }
    }

    /// A Boolean value indicating whether the web authentication session starts successfully.
    ///
    /// This method starts the AuthenticationSession instance after it is instantiated. It can only be called once for an AuthenticationSession instance. Calling start on a canceled session will fail.
    public func start() -> Bool {
        return innerAuthenticationSession.start()
    }

    /// Cancel a web authentication session.
    ///
    /// If the view controller is already presented to load the webpage for authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
    public func cancel() {
        innerAuthenticationSession.cancel()
    }
}

/// A class that manages sharing a one-time login between Safari and the app, which can also be used for automatic login for associated apps.
@available(iOS 11.0, *)
public protocol AuthenticationSessionProtocol {
    /// Returns a web authentication session object.
    ///
    /// - parameters:
    ///   - url: The initial URL pointing to the authentication webpage. Only supports URLs with http:// or https:// schemes.
    ///   - callbackURLScheme: The custom URL scheme that the app expects in the callback URL.
    ///   - completionHandler: The completion handler which is called when the session is completed successfully or canceled by user.
    init(url URL: URL,
         callbackURLScheme: String?,
         completionHandler: @escaping (URL?, Error?) -> Void)

    /// A Boolean value indicating whether the web authentication session starts successfully.
    ///
    /// This method starts the AuthenticationSession instance after it is instantiated. It can only be called once for an AuthenticationSession instance. Calling start on a canceled session will fail.
    func start() -> Bool

    /// Cancel a web authentication session.
    ///
    /// If the view controller is already presented to load the webpage for authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
    func cancel()
}

@available(iOS 11.0, *)
extension SFAuthenticationSession: AuthenticationSessionProtocol {
}

@available(iOS 12.0, *)
extension ASWebAuthenticationSession: AuthenticationSessionProtocol {
}

class AuthenticationSessionViewController: UIView, ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}
