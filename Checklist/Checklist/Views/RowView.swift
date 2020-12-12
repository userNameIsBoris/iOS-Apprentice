//
//  RowView.swift
//  Checklist
//
//  Created by Борис on 10.12.2020.
//

import SwiftUI

struct RowView: View {

    // Properties
    @Binding var checklistItem: ChecklistItem

    // UI content and layout
    var body: some View {
        NavigationLink(destination: EditChecklistItemView(checklistItem: $checklistItem)) {
            HStack {
                Text(checklistItem.name)

                Spacer()

                checklistItem.isChecked ? Image(systemName: "checkmark.circle.fill").foregroundColor(.green) : Image(systemName: "x.circle.fill").foregroundColor(.red)
            }
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(checklistItem: .constant(ChecklistItem(name: "Sample item")))
    }
}
