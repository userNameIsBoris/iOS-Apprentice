//
//  EditChecklistItemView.swift
//  Checklist
//
//  Created by Boris Ezhov on 10.12.2020.
//

import SwiftUI

struct EditChecklistItemView: View {
  // MARK: - Properties
  @Binding var checklistItem: ChecklistItem

  // MARK: - UI Content and Layout
  var body: some View {
    Form {
      TextField("Name", text: $checklistItem.name)
      Toggle("Completed", isOn: $checklistItem.isChecked)
    }
    .navigationBarTitle("Edit an item", displayMode: .inline)
  }
}

struct EditChecklistItemView_Previews: PreviewProvider {
  static let item = ChecklistItem(name: "Sample item")

  static var previews: some View {
    EditChecklistItemView(checklistItem: .constant(item))
  }
}
