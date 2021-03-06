//
//  Extensions.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/11/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import UIKit

extension String {

    static func random(length: Int = 6) -> String {
        let base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

extension UIViewController {
    func notifyUser(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert)

        let cancelAction = UIAlertAction(title: "OK",
            style: .cancel, handler: nil)

        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}
