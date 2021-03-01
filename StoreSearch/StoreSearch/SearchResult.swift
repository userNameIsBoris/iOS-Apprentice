//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Борис on 01.03.2021.
//

import Foundation

class SearchResult {
  var name: String
  var artistName: String

  init(name: String = "", artistName: String = "") {
    self.name = name
    self.artistName = artistName
  }
}
