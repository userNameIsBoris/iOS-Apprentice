//
//  ContentView.swift
//  Checklist
//
//  Created by Борис on 07.12.2020.
//

import SwiftUI

struct ChecklistView: View {

    // Properties
    @ObservedObject var checklist = Checklist()

    // UI content and layout
    var body: some View {
        NavigationView {
            List {
                ForEach(checklist.items) { checklistItem in
                    HStack {
                        Text(checklistItem.name)
                        
                        Spacer()
                            .background(Color.white)
                        
                        checklistItem.isChecked ? Text("✅") : Text("❎")
                    }
                    .background(Color.white)
                    .onTapGesture {
                        if let matchingIndex = checklist.items.firstIndex(where: {
                            $0.id == checklistItem.id
                        }) {
                            checklist.items[matchingIndex].isChecked.toggle()
                        }
                        checklist.printChecklistContents()
                    }
                }
                .onDelete(perform: { indexSet in
                    checklist.deleteListItem(whichElement: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    checklist.moveListItem(whichElement: indices, destination: newOffset)
                })
            }
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Checklist")
            .onAppear() {
                checklist.printChecklistContents()
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView()
            .previewDevice("iPhone 12 Pro")
    }
}

