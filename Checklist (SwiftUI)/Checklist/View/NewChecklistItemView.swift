//
//  NewChecklistItemView.swift
//  Checklist
//
//  Created by Boris Ezhov on 10.12.2020.
//

import SwiftUI

struct NewChecklistItemView: View {
  // MARK: - Properties
  @State private var newItemName = ""
  @Environment(\.presentationMode) private var presentationMode
  var checklist: Checklist

  // MARK: - UI Content and Layout
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
  static let checklist = Checklist()

  static var previews: some View {
    NewChecklistItemView(checklist: checklist)
  }
}
