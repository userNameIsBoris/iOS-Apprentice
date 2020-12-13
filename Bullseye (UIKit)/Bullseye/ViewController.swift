//
//  ViewController.swift
//  Bullseye
//
//  Created by Борис on 13.12.2020.
//

import UIKit

class ViewController: UIViewController {
    var sliderValue: Int = 50
    @IBOutlet weak var slider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.value = 50.0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showAlert() {
        let message = "The value of the slider is: \(sliderValue)"

        let alert = UIAlertController(title: "Hey", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Awesome", style: .default, handler: nil)
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    @IBAction func sliderMoved(_ sender: UISlider) {
        sliderValue = lroundf(sender.value)
    }
}

