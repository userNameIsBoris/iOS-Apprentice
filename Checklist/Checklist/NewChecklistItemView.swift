//
//  NewChecklistItemView.swift
//  Checklist
//
//  Created by Борис on 10.12.2020.
//

import SwiftUI

struct NewChecklistItemView: View {

    // Properties
    var checklist: Checklist
    @State var newItemName = ""
    @Environment(\.presentationMode) var presentationMode
    
    // UI content and layout
    var body: some View {
        VStack {
            Text("Add new item")
            Form {
                TextField("Enter item name", text: $newItemName)
                Button(action: {
                    let newChecklistItem = ChecklistItem(name: self.newItemName)
                    self.checklist.items.append(newChecklistItem)
                    self.checklist.printChecklistContents()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add item")
                    }
                }
                .disabled(newItemName.count == 0)
            }
            Text("Swipe down to cancel.")
        }
    }
}

struct NewChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewChecklistItemView(checklist: Checklist())
    }
}
