//
//  ViewController.swift
//  Bullseye
//
//  Created by Борис on 13.12.2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!

    var targetValue = 0
    var sliderValue = 0
    var score = 0
    var round = 0
    var sliderTargetDifference: Int {
        return abs(sliderValue - targetValue)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()

        // Thumb image for slider
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!

        // Track image for slider
        let sliderTrackLeft = UIImage(named: "SliderTrackLeft")!
        let sliderTrackRight = UIImage(named: "SliderTrackRight")!

        // Track image adjustments
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        let sliderTrackLeftResizable = sliderTrackLeft.resizableImage(withCapInsets: insets)
        let sliderTrackRightResizable = sliderTrackRight.resizableImage(withCapInsets: insets)

        // Applying changes to the slider
        slider.setThumbImage(thumbImageNormal, for: .normal)
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        slider.setMinimumTrackImage(sliderTrackLeftResizable, for: .normal)
        slider.setMaximumTrackImage(sliderTrackRightResizable, for: .normal)
    }

    @IBAction func sliderMoved(_ sender: UISlider) {
        sliderValue = lroundf(sender.value)
    }

    @IBAction func showAlert() {
        let message = """
        The value of the slider is: \(sliderValue)
        The target value is: \(targetValue)
        You scored \(pointsForCurrentRound) points
        """
        let title: String

        switch sliderTargetDifference {
        case 0:
            title = "Perfect!"
        case ...5:
            title = "You almost had it!"
        case ...10:
            title = "Pretty good!"
        default:
            title = "Not even close..."
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Awesome", style: .default,
                                   handler: { _ in
                                    self.startNewRound()
                                   })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func startOver(_ sender: UIButton) {
        startNewGame()
    }

    // Methods
    func startNewRound() {
        targetValue = Int.random(in: 1...100)
        sliderValue = 50
        score += pointsForCurrentRound
        round += 1
        updateLabels()
    }

    func startNewGame() {
        let transition = CATransition()
        transition.type = CATransitionType.fade
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: nil)

        addHighScore(score)

        targetValue = Int.random(in: 1...100)
        sliderValue = 50
        score = 0
        round = 0
        updateLabels()
    }

    func updateLabels() {
        targetLabel.text = String(targetValue)
        slider.value = Float(sliderValue)
        scoreLabel.text = String(score)
        roundLabel.text = String(round)
    }

    func addHighScore(_ score: Int) {
        guard score > 0 else {
            return
        }

        let highScore = HighScoreItem()
        highScore.score = score
        highScore.name = "Unknown"

        var highScores = PersistencyHelper.loadHighScores()
        highScores.append(highScore)
        highScores.sort(by: { $0.score > $1.score })
        PersistencyHelper.saveHighScores(highScores)
    }
}

