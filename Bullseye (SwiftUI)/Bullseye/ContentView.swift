//
//  ContentView.swift
//  Bullseye
//
//  Created by Boris Ezhov on 29.11.2020.
//

import SwiftUI

struct ContentView: View {
  // MARK: - Properties
  @State private var alertIsVisible = false
  @State private var sliderValue = 50.0
  @State private var target = Int.random(in: 1...100)
  @State private var roundNumber = 1
  @State private var score = 0

  private var sliderValueRounded: Int {
      Int(round(sliderValue))
  }
  private var sliderTargetDifference: Int {
    return abs(sliderValueRounded - target)
  }
  private var alertTitle: String {
    switch sliderTargetDifference {
    case 0:
      return "Perfect!"
    case _ where sliderTargetDifference <= 5:
      return "You almost had it!"
    case _ where sliderTargetDifference <= 10:
      return "Not bad."
    default:
      return "Are you even trying?"
    }
  }
  private var scoringMesage: String {
    """
      The slider value is: \(sliderValueRounded).
      The target value is: \(target).
      You scored \(pointsForCurrentRound) points for this round.
    """
  }
  private var pointsForCurrentRound: Int {
    let maximumScore = 100
    let points = maximumScore - sliderTargetDifference

    switch points {
    case maximumScore:
      return 200
    case maximumScore - 1:
      return 150
    default:
      return points
    }
  }

  // MARK: - UI Content and Layout
  var body: some View {
    NavigationView {
      VStack {
        Spacer()
          .navigationTitle(Text("🎯 Bullseye 🎯"))

        // Target row
        HStack {
          Text("Pull the bullseye as close as you can to:")
            .modifier(LabelStyle())
          Text("\(target)")
            .modifier(ValueStyle())
        }
        Spacer()

        // Slider row
        HStack {
          Text("1").modifier(ValueStyle())
          Slider(value: $sliderValue, in: 1...100)
            .accentColor(.green)
            .animation(.easeOut)
          Text("100")
            .modifier(ValueStyle())
        }
        Spacer()

        // Buttton row
        Button(action: {
          alertIsVisible = true
        }) {
          Text("Hit me!").modifier(ButtonLargeTextStyle())
            .modifier(ButtonBackgroundAndShadow())
        }
        .alert(isPresented: $alertIsVisible, content: {
          Alert(title: Text(alertTitle), message: Text(scoringMesage), dismissButton: .default(Text("Awesome!")) {
            startNewRound()
          })
        })
        Spacer()

        // Score row
        HStack {
          Button(action: {
            startNewGame()
          }) {
            HStack {
              Image("StartOverIcon")
              Text("Start over")
                .modifier(ButtonSmallTextStyle())
            }
            .modifier(ButtonBackgroundAndShadow())
          }
          Spacer()
          Text("Score:")
            .modifier(LabelStyle())
          Text("\(score)")
            .modifier(ValueStyle())
          Spacer()
          Text("Round:")
            .modifier(LabelStyle())
          Text("\(roundNumber)")
            .modifier(ValueStyle())
          Spacer()
          NavigationLink(destination: AboutView()) {
            HStack {
              Image("InfoIcon")
              Text("Info")
                .modifier(ButtonSmallTextStyle())
            }
            .modifier(ButtonBackgroundAndShadow())
          }
        }
        .padding(.bottom, 20)
      }
      .onAppear() {
        startNewGame()
      }
      .background(Image("Background"))
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  // MARK: - Helper Methods
  private func startNewRound() {
    score += pointsForCurrentRound
    roundNumber += 1
    resetTargetAndSlider()
  }

  private func startNewGame() {
    score = 0
    roundNumber = 1
    resetTargetAndSlider()
  }

  private func resetTargetAndSlider() {
    target = Int.random(in: 1...100)
    sliderValue = Double.random(in: 1...100)
  }

  // MARK: - View Modifieres
  private struct LabelStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(Font.custom("Arial Rounded MT Bold", size: 18))
        .foregroundColor(.white)
        .modifier(Shadow())
    }
  }

  private struct ValueStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(Font.custom("Arial Rounded MT Bold", size: 24))
        .foregroundColor(.yellow)
        .modifier(Shadow())
    }
  }

  private struct Shadow: ViewModifier {
    func body(content: Content) -> some View {
      content
        .shadow(color: .black, radius: 5, x: 2, y: 2)
    }
  }

  private struct ButtonLargeTextStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(Font.custom("Arial Rounded MT Bold", size: 18))
        .foregroundColor(.black)
    }
  }

  private struct ButtonSmallTextStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(Font.custom("Arial Rounded MT Bold", size: 12))
        .foregroundColor(.black)
    }
  }

  private struct ButtonBackgroundAndShadow: ViewModifier {
    func body(content: Content) -> some View {
      content
        .background(Image("Button"))
        .modifier(Shadow())
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
