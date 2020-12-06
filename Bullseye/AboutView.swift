//
//  AboutView.swift
//  Bullseye
//
//  Created by Борис on 06.12.2020.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        // Colors
        let biege = Color(red: 1.0, green: 0.84, blue: 0.7)
        Group {
            VStack {
                Text("🎯 Bullseye 🎯")
                    .modifier(AboutHeadingStyle())
                Text("This is Bullseye, the game where you can win points and earn fame by dragging a slider.")
                    .modifier(AboutBodyStyle())
                Text("Your goal is to place the slider as close as possible to the target value. The closer you are, the more points you score.")
                    .modifier(AboutBodyStyle())
                Text("Enjoy!")
                    .modifier(AboutBodyStyle())
            }
            .background(biege)
        }
        .background(Image("Background"))
    }
    // View modifiers
    struct AboutHeadingStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.custom("Arial Rounded MT Bold", size: 30))
                .foregroundColor(.black)
                .padding(.vertical, 20)
        }
    }
    struct AboutBodyStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.custom("Arial Rounded MT Bold", size: 16))
                .foregroundColor(.black)
                .padding(.horizontal, 60)
                .padding(.bottom, 20)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
