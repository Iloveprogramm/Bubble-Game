//  ViewController.swift
//  BubbleGame
//  Created by Chenjun Zheng 14208603
//  Language: Swift

import UIKit
import AVFoundation

class Bubble: UIButton {

    // Specify the properties
    var value: Int = 0
    var color: UIColor!
    let screenSize: CGRect = UIScreen.main.bounds

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Generate a random view position
        self.frame = CGRect(x: CGFloat(Int.random(in: 60...Int(screenSize.width - 90))),
            y: CGFloat(Int.random(in: 150...Int(screenSize.height - 120))),
            width: 80, height: 80)
        // According to the probability, set the backdrop colour and its associated value.
        let probabilityOfAppearance = Int.random(in: 0..<100)
        // Set background colour and value based on probability
        var backgroundColor: UIColor
        var value: Int
        var color: UIColor
        switch probabilityOfAppearance {
        case 0...39:
            backgroundColor = UIColor.red
            value = 1
            color = UIColor.red
        case 40...69:
            backgroundColor = UIColor(red: 1, green: 192 / 255, blue: 203 / 255, alpha: 1)
            value = 2
            color = UIColor(red: 1, green: 192 / 255, blue: 203 / 255, alpha: 1)
        case 70...84:
            backgroundColor = UIColor.green
            value = 5
            color = UIColor.green
        case 85...94:
            backgroundColor = UIColor.blue
            value = 8
            color = UIColor.blue
        case 95...99:
            backgroundColor = UIColor.black
            value = 10
            color = UIColor.black
        default:
            return
        }
        //Change the colour, value, and background colour to the corresponding values.
        self.backgroundColor = backgroundColor
        self.value = value
        self.color = color
        // Set the rounded corners of the view
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }


    //If the initialization method is called,
    //the program will crash and print the error message "init(coder:) has not been implemented".
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Create the Bubble object based on the amount of time left.
    init(remainingTime: Int) {
        self.init()
        adjustAnimationSpeed(remainingTime: remainingTime)
    }

    // Adapt the animation's speed to the amount of time left.
    func adjustAnimationSpeed(remainingTime: Int) {
        var speed = Double(remainingTime) / 60.0
        if speed < 0.5 {
            speed = 0.5
        }
        let duration = 2 * speed
        self.bubbleAnimation(duration: duration)
    }

    func bubbleAnimation(duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }

    //Perform animation method
    func performTapAnimation() {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

