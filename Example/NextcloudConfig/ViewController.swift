//
//  ViewController.swift
//  NextcloudConfig
//
//  Created by Sean Molenaar on 03/30/2019.
//  Copyright (c) 2019 Sean Molenaar. All rights reserved.
//

import UIKit
import NextcloudConfig

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    var webAuthSession: AuthenticationSessionProtocol!

    //var url: String = "https://demo1.nextcloud.com"
    var url: String = "https://cloud.seanmolenaar.eu/nextcloud"
    var config: NextcloudConfig? {
        guard let url = URL(string: self.url) else {
            return nil
        }

        return NextcloudConfig(baseURL: url)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        urlField.text = url
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureLabel()
    }

    @IBAction func didPressLogin() {
        self.url = urlField.text ?? url
        configureLabel()
        config?.loginSession { result in
            switch(result) {
            case .success(let session):
                self.webAuthSession = session
                let _ = self.webAuthSession.start()
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func configureLabel() {
        config?.fetch(path: "ocs/v1.php/cloud/capabilities", type: WebserviceResponse<CapabilitiesResponse>.self) { result in
            var text: String
            var color: UIColor = UIColor.black
            switch result {
            case .success(let fetchedConfig):
                guard let theming = fetchedConfig.ocs.data?.capabilities?.theming else {
                        debugPrint("Empty data", fetchedConfig)
                        return
                }
                text = "\(theming.name) - \(theming.slogan)"
                color = StringColor.fromString(theming.color) ?? UIColor.black
            case .failure(let error):
                text = error.localizedDescription
            }
            DispatchQueue.main.async {
                self.label.text = text
                self.label.textColor = color
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
