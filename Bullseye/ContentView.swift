//
//  ContentView.swift
//  Bullseye
//
//  Created by Борис on 29.11.2020.
//

import SwiftUI

struct ContentView: View {
    // UI Views
    
    //Properties
    
    // Colors
    let midnightBlue = Color(red: 0, green: 0.2, blue: 0.4)
    @State var alertIsVisible = false
    @State var sliderValue = 50.0 {
        didSet {
            print(sliderValue)
        }
    }
    var sliderValueRounded: Int {
        Int(round(sliderValue))
    }
    @State var roundNumber = 1
    @State var score = 0
    @State var target = Int.random(in: 1...100)
    var sliderTargetDifference: Int {
        return abs(sliderValueRounded - target)
    }
    var alertTitle: String {
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
    var scoringMesage: String {
        """
            The slider value is: \(sliderValueRounded).
            The target value is: \(target).
            You scored \(pointsForCurrentRound) points for this round.
        """
    }
    var pointsForCurrentRound: Int {
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
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .navigationTitle(Text("🎯 Bullseye 🎯"))
                
                // Target row
                HStack {
                    Text("Pull the bullseye as close as you can to:").modifier(LabelStyle())
                    Text("\(target)").modifier(ValueStyle())
                }
                Spacer()
                
                // Slider row
                HStack {
                    Text("1").modifier(ValueStyle())
                    
                    Slider(value: $sliderValue, in: 1...100)
                        .onChange(of: sliderValue, perform: { value in
                            print(Int(round(value)))
                        })
                        .accentColor(.green)
                        .animation(.easeOut)
                    Text("100").modifier(ValueStyle())
                }
                Spacer()
                
                // Buttton row
                Button(action: {
                    alertIsVisible = true
                }) {
                    Text("Hit me!").modifier(ButtonLargeTextStyle())
                }
                .background(Image("Button"))
                .modifier(Shadow())
                
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
                                Text("Start over").modifier(ButtonSmallTextStyle())
                            }
                            .background(Image("Button"))
                            .modifier(Shadow())
                        }
                    
                    Spacer()
                    Text("Score:").modifier(LabelStyle())
                    Text("\(score)").modifier(ValueStyle())
                    Spacer()
                    Text("Round:").modifier(LabelStyle())
                    Text("\(roundNumber)").modifier(ValueStyle())
                    Spacer()
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image("InfoIcon")
                            Text("Info").modifier(ButtonSmallTextStyle())
                        }
                        .background(Image("Button"))
                        .modifier(Shadow())
                    }
                }
                .accentColor(midnightBlue)
                .padding(.bottom, 20)
            }
            .onAppear() {
                startNewGame()
            }
            .background(Image("Background"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Methods
    func startNewRound() {
        score += pointsForCurrentRound
        roundNumber += 1
        resetTargetAndSlider()
    }
    func startNewGame() {
        score = 0
        roundNumber = 1
        resetTargetAndSlider()
    }
    func resetTargetAndSlider() {
        target = Int.random(in: 1...100)
        sliderValue = Double.random(in: 1...100)
    }
    
    // View modifieres
    struct LabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.custom("Arial Rounded MT Bold", size: 18))
                .foregroundColor(.white)
                .modifier(Shadow())
        }
    }
        struct ValueStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.custom("Arial Rounded MT Bold", size: 24))
                .foregroundColor(.yellow)
                .modifier(Shadow())
        }
    }
    struct Shadow: ViewModifier {
        func body(content: Content) -> some View {
            content
            .shadow(color: .black, radius: 5, x: 2, y: 2)
        }
    }
    struct ButtonLargeTextStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.custom("Arial Rounded MT Bold", size: 18))
                .foregroundColor(.black)
        }
    }
    struct ButtonSmallTextStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.custom("Arial Rounded MT Bold", size: 12))
                .foregroundColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.device)
            .previewDevice("iPhone Xs")
    }
}
