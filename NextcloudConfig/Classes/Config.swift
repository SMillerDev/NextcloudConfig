//
//  Config.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 30/03/2019.
//

import Foundation

public struct Config: Codable {
    let data: DataResponse?
}

public struct DataResponse: Codable {
    let version: Version?
    let capabilities: Capabilities?
}

public struct Version: Codable {
    let major: Int
    let minor: Int
    let micro: Int
    let string: String
    let edition: String?
}

public struct Capabilities: Codable {
}
