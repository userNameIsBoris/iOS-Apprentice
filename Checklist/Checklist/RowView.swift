//
//  RowView.swift
//  Checklist
//
//  Created by Борис on 10.12.2020.
//

import SwiftUI

struct RowView: View {
    
    @Binding var checklistItem: ChecklistItem
    
    var body: some View {
        NavigationLink(destination: EditChecklistItemView(checklistItem: $checklistItem)) {
            HStack {
                Text(checklistItem.name)
                
                Spacer()
    //                .background(Color.white)
                
                checklistItem.isChecked ? Text("✅") : Text("❎")
            }
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(checklistItem: .constant(ChecklistItem(name: "Sample item")))
    }
}
