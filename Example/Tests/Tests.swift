import NextcloudConfig
import XCTest
import Foundation

class NextcloudConfigTests: XCTestCase {
    func testConfigFetching() {
        let expectation = XCTestExpectation(description: "Webservice request")
        guard let url = URL(string: "https://demo15.nextcloud.bayton.org") else {
            return
        }
        let config = NextcloudConfig(baseURL: url)
        config.fetch(path: "ocs/v1.php/cloud/capabilities", type: WebserviceResponse<CapabilitiesResponse>.self) { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.get()?.version?.major)
                XCTAssertNotNil(response.get()?.capabilities)
                XCTAssertNotNil(response.get()?.capabilities?.theming)
                XCTAssertNotNil(response.get()?.capabilities?.theming?.name)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
