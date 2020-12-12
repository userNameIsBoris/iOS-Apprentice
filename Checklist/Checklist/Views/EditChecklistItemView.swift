//
//  EditChecklistItemView.swift
//  Checklist
//
//  Created by Борис on 10.12.2020.
//

import SwiftUI

struct EditChecklistItemView: View {

    // Properties
    @Binding var checklistItem: ChecklistItem

    // UI content and layout
    var body: some View {
        Form {
            TextField("Name", text: $checklistItem.name)

            Toggle("Completed", isOn: $checklistItem.isChecked)
        }
        .navigationBarTitle("Edit an item", displayMode: .inline)
    }
}

struct EditChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditChecklistItemView(checklistItem: .constant(ChecklistItem(name: "Sample item")))
    }
}
