//
//  UIKitExtensions.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import UIKit


#warning("TODO: Test colour blending")
extension UIColor {
    struct RGB {
        var r: CGFloat
        var g: CGFloat
        var b: CGFloat
        var a: CGFloat
    }
    var rgb: RGB {
        var output = RGB(r: 0, g: 0, b: 0, a: 0)
        getRed(&output.r, green: &output.g, blue: &output.b, alpha: &output.a)
        return output
    }
    func blend(with other: UIColor, by t: CGFloat) -> UIColor {
        let s = rgb
        let d = other.rgb
        return UIColor(
            red:    (s.r * (1.0 - t)) + (d.r * t),
            green:  (s.g * (1.0 - t)) + (d.g * t),
            blue:   (s.b * (1.0 - t)) + (d.b * t),
            alpha:  (s.a * (1.0 - t)) + (d.a * t)
        )
    }
}
