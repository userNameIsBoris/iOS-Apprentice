//
//  UIImage+CornerRadius.swift
//  StoreSearch
//
//  Created by Борис on 05.03.2021.
//

import UIKit

extension UIImage {
  func withCornerRadius(_ radius: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    let rect = CGRect(origin: .zero, size: size)
    UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
    draw(in: rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
  }
}
