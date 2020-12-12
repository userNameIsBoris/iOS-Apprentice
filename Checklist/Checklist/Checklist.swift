//
//  Checklist.swift
//  Checklist
//
//  Created by Борис on 08.12.2020.
//

import Foundation

class Checklist: ObservableObject {
    // Properties
    @Published var items: [ChecklistItem] = [] {
        didSet {
            saveListItems()
        }
    }

    // Initializers
    init() {
//        print("Documents directory is: \(documentDirectory())")
//        print("Data file path is: \(dataFilePath())")
        loadListItems()
    }

    // Methods
    func printChecklistContents() {
        print()
        print("Beginning ———————————————————————————————————————————")
        for item in items {
            print(item)
        }
        print("End —————————————————————————————————————————————————")
    }

    func deleteListItem(whichElement: IndexSet) {
        items.remove(atOffsets: whichElement)
        printChecklistContents()
    }

    func deleteAllItems() {
        items.removeAll()
        printChecklistContents()
    }

    func moveListItem(whichElement: IndexSet, destination: Int) {
        items.move(fromOffsets: whichElement, toOffset: destination)
        printChecklistContents()
    }

    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("Checklist.plist")
    }

    func saveListItems() {
        let encoder = PropertyListEncoder()

        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }

    func loadListItems() {
        let path = dataFilePath()

        guard let data = try? Data(contentsOf: path) else {
            return
        }

        let decoder = PropertyListDecoder()

        do {
            items = try decoder.decode([ChecklistItem].self, from: data)
        } catch {
            print("Error decoding item array: \(error.localizedDescription)")
        }
    }
}
