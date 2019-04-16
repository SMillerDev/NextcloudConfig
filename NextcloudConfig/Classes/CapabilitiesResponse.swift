//
//  CapabilitiesResponse.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation

public struct CapabilitiesResponse: Codable {
    public let version: Version?
    public let capabilities: Capabilities?
}

public struct Version: Codable {
    public let major: Int
    let minor: Int
    let micro: Int
    let string: String
    let edition: String?
}

public struct Capabilities: Codable {
    public let core: CoreCapabilities?
    public let theming: ThemingCapabilities?
}

public struct CoreCapabilities: Codable {

}

public struct ThemingCapabilities: Codable {
    public let name: String
    public let url: String
    public let logo: String
    public let background: String
    public let slogan: String
    public let color: String
}
