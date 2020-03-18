//
//  LoginResponse.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 18/03/2020.
//

import Foundation

/// Webservice wrapper for login v2
public struct LoginResponse: Codable {
    /// Poll data
    public let poll: LoginPollResponse
    
    /// Login url
    public let login: String
}

/// Wrapper for login v2 poll data
public struct LoginPollResponse: Codable {
    /// Poll token
    public let token: String
    /// Poll endpoint
    public let endpoint: String
}
