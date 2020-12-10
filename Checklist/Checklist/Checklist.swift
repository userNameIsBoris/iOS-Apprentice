//
//  Checklist.swift
//  Checklist
//
//  Created by Борис on 08.12.2020.
//

import Foundation

class Checklist: ObservableObject {
    // Properties
    @Published var items = [
        ChecklistItem(name: "Walk the dog", isChecked: false),
          ChecklistItem(name: "Brush my teeth", isChecked: false),
          ChecklistItem(name: "Learn iOS development", isChecked: true),
          ChecklistItem(name: "Soccer practice", isChecked: false),
          ChecklistItem(name: "Eat ice cream", isChecked: false),
    ]

    // Methods
    func printChecklistContents() {
        for item in items {
            print(item)
        }
    }

    func deleteListItem(whichElement: IndexSet) {
        items.remove(atOffsets: whichElement)
        printChecklistContents()
    }

    func moveListItem(whichElement: IndexSet, destination: Int) {
        items.move(fromOffsets: whichElement, toOffset: destination)
        printChecklistContents()
    }

    func changeIsChecked(whichElement: IndexSet) {
        guard whichElement.first == whichElement.last else {
            return
        }
        guard let index = whichElement.first else {
            return
        }

        items[index].isChecked = !items[index].isChecked
    }
}
