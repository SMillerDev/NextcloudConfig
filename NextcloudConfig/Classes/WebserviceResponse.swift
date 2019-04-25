//
//  WebserviceResponse.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 25/04/2019.
//

import Foundation

/// Webservice wrapper for nextcloud requests.
public struct WebserviceResponse<T: Codable>: Codable {
    /// Wrapper for response
    public let ocs: WebserviceOcsResponse<T>

    /// Convenience method to get the data right away
    /// - returns: The contained API data
    public func get() -> T? {
        return ocs.data
    }
}

/// Webservice wrapper for nextcloud requests that contains the data and status.
public struct WebserviceOcsResponse<T: Codable>: Codable {
    /// Data returned in the webservice
    public let data: T?
    /// Wrapper for response metadata (status and others)
    public let meta: WebserviceMeta
}

/// Webservice metadata.
public struct WebserviceMeta: Codable {
    /// Status of the webservice as a string
    public let status: String
    /// HTTP Statuscode from the webservice
    public let statuscode: Int
    /// Webservice message
    public let message: String

    /// Optional amount of items returned
    public let totalitems: String?
    /// Optional amount of items returned on this page
    public let itemsperpage: String?
}
