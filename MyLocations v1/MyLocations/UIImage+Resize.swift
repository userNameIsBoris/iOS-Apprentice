//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Борис on 13.01.2021.
//

import UIKit

extension UIImage {
  func resized(withBounds bounds: CGSize) -> UIImage {
    let horizontalRatio = bounds.width / size.width
    let verticalRatio = bounds.height / size.height
    let ratio = min(horizontalRatio, verticalRatio)
    let shortestSide = min(size.width, size.height)
    let newSize = CGSize(width: shortestSide * ratio, height: shortestSide * ratio)

    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return newImage
  }
}
