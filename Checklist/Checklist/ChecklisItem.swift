//
//  ChecklisItem.swift
//  Checklist
//
//  Created by Борис on 08.12.2020.
//

import Foundation

// Structs
struct ChecklistItem: Identifiable {
    let id = UUID()
    var name: String //= ""
    var isChecked = false
}
