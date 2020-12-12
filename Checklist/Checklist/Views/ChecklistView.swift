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
    @State var newChecklistItemViewIsVisible = false
    @State var isEditing = false
    var isDisabled: Bool {
        isEditing && checklist.items.count == 0 ? true : false
    }

    // UI content and layout
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(checklist.items) { RowView(checklistItem: $checklist.items[$0]) }
                        .onDelete(perform: { checklist.deleteListItem(whichElement: $0) })
                        .onMove(perform: { checklist.moveListItem(whichElement: $0, destination: $1) })
                }

                // Navigation Bar Items

                // Leading item
                .navigationBarItems(leading: Button(action: {
                    if isEditing {
                        checklist.deleteAllItems()
                    } else {
                        newChecklistItemViewIsVisible = true
                    }
                }, label: {
                    HStack {
                        Image(systemName: (isEditing ? "minus.circle.fill" : "plus.circle.fill"))

                        Text(isEditing ? "Delete all" : "Add item")
                    }
                    .foregroundColor(isEditing ? (isDisabled ? .gray : .red) : .accentColor)
                })
                .disabled(isDisabled),

                // Trailing item
                trailing: Button(action: {
                    isEditing.toggle()
                }, label: {
                    Text(isEditing ? "Done" : "Edit")
                }))
                .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
                .animation(Animation.default)

                .navigationBarTitle("Checklist", displayMode: .inline)
            }
        }
        .sheet(isPresented: $newChecklistItemViewIsVisible, content: { NewChecklistItemView(checklist: checklist) })
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView()
            .previewDevice("iPhone 12 Pro")
    }
}
