//
//  ContentView.swift
//  Checklist
//
//  Created by Борис on 07.12.2020.
//

import SwiftUI

// Structs
struct ChecklistItem: Identifiable {
    let id = UUID()
    var name: String //= ""
    var isChecked = false
}

struct ContentView: View {
    
    // Properties
    @State var checklistItems = [
        ChecklistItem(name: "Walk the dog", isChecked: false),
          ChecklistItem(name: "Brush my teeth", isChecked: false),
          ChecklistItem(name: "Learn iOS development", isChecked: true),
          ChecklistItem(name: "Soccer practice", isChecked: false),
          ChecklistItem(name: "Eat ice cream", isChecked: false),
//        ChecklistItem(name: <#T##String#>),
//        ChecklistItem(name: <#T##String#>),
//        ChecklistItem(name: <#T##String#>),
//        ChecklistItem(name: <#T##String#>),
//        ChecklistItem(name: <#T##String#>),
    ]
    
    // UI content and layout
    var body: some View {
        NavigationView {
            List {
                ForEach(checklistItems) { checklistItem in
                    HStack {
                        Text(checklistItem.name)
                        
                        Spacer()
                            .background(Color.white)
                        
                        checklistItem.isChecked ? Text("✅") : Text("❎")
                    }
                    .background(Color.white)
                    .onTapGesture {
                        if let matchingIndex = self.checklistItems.firstIndex(where: {
                            $0.id == checklistItem.id
                        }) {
                            checklistItems[matchingIndex].isChecked.toggle()
                        }
                        printChecklistContents()
                    }
                }
                .onDelete(perform: { indexSet in
                    deleteListItem(whichElement: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    moveListItem(whichElement: indices, destination: newOffset)
                })
            }
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Checklist")
            .onAppear() {
                self.printChecklistContents()
            }
        }
    }

    // Methods
    func printChecklistContents() {
        for item in checklistItems {
            print(item)
        }
    }

    func deleteListItem(whichElement: IndexSet) {
        checklistItems.remove(atOffsets: whichElement)
        printChecklistContents()
    }

    func moveListItem(whichElement: IndexSet, destination: Int) {
        checklistItems.move(fromOffsets: whichElement, toOffset: destination)
        printChecklistContents()
    }
    
    func changeIsChecked(whichElement: IndexSet) {
        guard whichElement.first == whichElement.last else {
            return
        }
        guard let index = whichElement.first else {
            return
        }

        checklistItems[index].isChecked = !checklistItems[index].isChecked
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro")
    }
}

