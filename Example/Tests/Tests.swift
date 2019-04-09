import NextcloudConfig
import XCTest
import Foundation

class TableOfContents: XCTestCase {
    func testMain() {
        guard let url = URL(string: "https://cloud.seanmolenaar.eu") else {
            return
        }

        let config = NextcloudConfig(baseURL: url, sessionConfig: URLSessionConfiguration())
        config.fetch()
        XCTAssertNotNil(config.config)
    }
}
