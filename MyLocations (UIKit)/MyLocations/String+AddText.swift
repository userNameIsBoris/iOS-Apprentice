//
//  String+AddText.swift
//  MyLocations
//
//  Created by Boris Ezhov on 22.02.2021.
//

import Foundation

extension String {
  mutating func add(text: String?, separatedBy separator: String = "") {
    if let text = text {
      if !isEmpty {
        self += separator
      }
      self += text
    }
  }
}
