//
//  CapabilitiesResponse.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation

/// Object describing the nextcloud server capabilities API
public struct CapabilitiesResponse: Codable {
    /// Server version object
    public let version: Version?
    /// Server capabilities object
    public let capabilities: Capabilities?
}

/// Object describing the nextcloud server version
public struct Version: Codable {
    /// Server major version
    public let major: Int
    /// Server minor version
    let minor: Int
    /// Server micro version
    let micro: Int
    /// Server version string
    let string: String
    /// Server edition
    let edition: String?
}

/// Object describing the nextcloud server capabilities
public struct Capabilities: Codable {
    /// Server core capabilities
    public let core: CoreCapabilities?
    /// Server theming capabilities
    public let theming: ThemingCapabilities?
}

/// Object describing the nextcloud server core capabilities
public struct CoreCapabilities: Codable {

}

/// Object describing the nextcloud server theming capabilities
public struct ThemingCapabilities: Codable {
    /// Server name
    public let name: String
    /// Server url
    public let url: String
    /// Server logo URL
    public let logo: String
    /// Server background URL
    public let background: String
    /// Server slogan
    public let slogan: String
    /// Server main color hexadecimal
    public let color: String
}
