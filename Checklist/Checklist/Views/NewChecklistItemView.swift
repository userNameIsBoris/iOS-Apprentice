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
                .padding(.top)

            Form {
                TextField("Enter item name", text: $newItemName)

                Button(action: {
                    let newChecklistItem = ChecklistItem(name: newItemName)
                    checklist.items.append(newChecklistItem)
                    presentationMode.wrappedValue.dismiss()
                    self.checklist.printChecklistContents()
                }, label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")

                        Text("Add item")
                    }
                })
                .disabled(newItemName.count == 0)
            }
            HStack {
                Image(systemName: "chevron.down.circle.fill")

                Text("Swipe down to cancel")
            }
            .foregroundColor(.gray)
            .padding(.bottom)
        }
    }
}

struct NewChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewChecklistItemView(checklist: Checklist())
    }
}
