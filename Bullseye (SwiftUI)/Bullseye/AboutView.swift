//
//  AboutView.swift
//  Bullseye
//
//  Created by Boris Ezhov on 06.12.2020.
//

import SwiftUI

struct AboutView: View {
  var body: some View {
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
      .background(Color("Biege"))
      .cornerRadius(10.0)
    }
    .background(Image("Background"))
    .navigationTitle("About Bullseye")
  }

  // MARK: - View Modifiers
  private struct AboutHeadingStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(Font.custom("Arial Rounded MT Bold", size: 30))
        .foregroundColor(.black)
        .padding(.vertical, 20)
    }
  }

  private struct AboutBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(Font.custom("Arial Rounded MT Bold", size: 16))
        .foregroundColor(.black)
        .padding(.horizontal, 80)
        .padding(.bottom, 20)
    }
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
  }
}
