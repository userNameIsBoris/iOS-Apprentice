//
//  String+AddText.swift
//  MyLocations
//
//  Created by Борис on 14.01.2021.
//

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
