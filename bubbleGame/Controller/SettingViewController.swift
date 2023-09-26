//  SettingViewController.swift
//  BubbleGame
//  Created by Chenjun Zheng 14208603
//  Language: Swift

import UIKit

// Set up the page setting view controller
class SettingViewController: UIViewController {
    //The user may specify the duration of the game and the amount of bubbles to be used.
    var maximumTime = 60
    var totalBubbles = 15

    // User interface elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var MaxBubbles: UILabel!
    @IBOutlet weak var MaxBubblesSlider: UISlider!

    // When the user adjusts the time slider, the overall game time is updated.
    @IBAction func timeSlider(_ sender: UISlider) {
        maximumTime = Int(sender.value)
        TimeLabel.text = String(maximumTime) + " sec"
    }

    // When the user adjusts the bubble count slider, the game's bubble total is updated.
    @IBAction func MaxBubblesSlides(_ sender: UISlider) {
        totalBubbles = Int(sender.value)
        MaxBubbles.text = String(totalBubbles)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Before starting the segue, make sure the username is correct.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToGame" {
            let name = nameTextField.text ?? ""
            if Valiadation(name) {
                return true
            } else {
                showInvalidInput()
                return false
            }
        }
        return true
    }

    // Verify that the username is correct.
    private func Valiadation(_ name: String) -> Bool {
        let inputName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !inputName.isEmpty
    }

    // Warning for an incorrect username
    private func showInvalidInput() {
        let error = UIAlertController(title: "Error", message: "Please enter a valid username", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Sure", style: .default, handler: nil)
        error.addAction(okAction)
        present(error, animated: true, completion: nil)
    }

    // implement segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let VC = segue.destination as! GameViewController
            VC.name = nameTextField.text!
            VC.remainingTime = Int(timeSlider.value)
            VC.totalBubbles = Int(MaxBubblesSlider.value)
        }
    }
}
