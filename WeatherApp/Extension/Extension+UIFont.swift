//
//  Extension+UIFont.swift
//  WeatherApp
//
//  Created by Bob Yin on 2025/10/2.
//

import UIKit

extension UIFont {

    static func PingFangTCMedium(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangTC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func PingFangTCRegular(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangTC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

}
