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

    // UI content and layout
    var body: some View {
        NavigationView {
            List {
                ForEach(checklist.items) { index in
                    RowView(checklistItem: self.$checklist.items[index])
//                    .background(Color.white)
                }
                .onDelete(perform: { indexSet in
                    checklist.deleteListItem(whichElement: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    checklist.moveListItem(whichElement: indices, destination: newOffset)
                })
            }
            .navigationBarItems(
              leading: Button(action: { self.newChecklistItemViewIsVisible =
            true }) {
                HStack {
                  Image(systemName: "plus.circle.fill")
                    
                  Text("Add item")
                }
              }, trailing: EditButton())
            .navigationBarTitle("Checklist", displayMode: .inline)
            .onAppear() {
                checklist.printChecklistContents()
            }
        }
        .sheet(isPresented: $newChecklistItemViewIsVisible, content: {
            NewChecklistItemView(checklist: self.checklist)
        })
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView()
            .previewDevice("iPhone 12 Pro")
    }
}

