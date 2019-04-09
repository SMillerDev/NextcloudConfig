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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let url = URL(string: "https://cloud.seanmolenaar.eu") else {
            return
        }

        let config = NextcloudConfig(baseURL: url)
        config.fetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

