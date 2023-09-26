//  GameViewController.swift
//  BubbleGame
//  Created by Chenjun Zheng 14208603
//  Language: Swift

import UIKit

// This class represents the main game view controller
class GameViewController: UIViewController {

    // Outlets for labels and scores
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var initialCountdownLabel: UILabel!
    @IBOutlet weak var BubbleScore: UILabel!
    @IBOutlet weak var BubbleHighScore: UILabel!

    // Game properties
    var name: String?
    var remainingTime = 60
    var countdownTime = 3
    var timer = Timer()
    var bubbleScore: Int = 0
    var bubbleTimer: Timer!
    var totalBubbles = 15
    var lastClickedBubbleColor: UIColor?
    var bubbleGenerationTime: TimeInterval = 1.0

    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        super.viewDidLoad()
        remainingTimeLabel.text = String(remainingTime)
        openCountdown()
        let leaderboard = UserDefaults.standard.dictionary(forKey: "leaderboard") as? [String: Int] ?? [String: Int]()
        let highestScore = leaderboard.values.max() ?? 0
        BubbleHighScore.text = " \(highestScore)"
    }

    // Start the initial countdown before the game starts
    func openCountdown() {
        let countdownHandler: (Timer) -> Void = { timer in
            self.countdownTime -= 1
            if self.countdownTime == 0 {
                timer.invalidate()
                self.gameStart()
            } else {
                self.updateInitialCountdownLabelText()
            }
        }
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: countdownHandler)
    }
    
    func updateInitialCountdownLabelText() {
        self.initialCountdownLabel.text = "\(self.countdownTime)"
    }

    // Start the game
    func gameStart() {
        initialCountdownLabel.text = "Start Game!"
        remainingTimeLabel.text = String(remainingTime)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.startCounting()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.initialCountdownLabel.isHidden = true
            self.bubbleTimer = Timer.scheduledTimer(timeInterval: self.bubbleGenerationTime, target: self, selector: #selector(self.generateRandomBubbles), userInfo: nil, repeats: true)
        }
    }

    // Create random bubbles on the screen
    @objc func generateRandomBubbles() {
        removeRandomBubbles()
        createRandomBubbles()
        resetBubbleTime()
    }
    
    //function of remove bubbles
    func removeRandomBubbles() {
        deleteRandomBubbles()
    }

    //function of create random bubbles
    func createRandomBubbles() {
        let currentExistBubbles = self.view.subviews.compactMap({ $0 as? Bubble }).count
        let maximumNewBubbles = totalBubbles - currentExistBubbles
        let numberOfBubbles = Int.random(in: 0...maximumNewBubbles)
        generateMultipleBubbles(numberOfBubbles: numberOfBubbles)
    }

    //function of reset the bubble timer
    func resetBubbleTime() {
        bubbleTimer.invalidate()
        bubbleTimer = Timer.scheduledTimer(timeInterval: bubbleGenerationTime, target: self, selector: #selector(generateRandomBubbles), userInfo: nil, repeats: true)
    }

    // Delete random bubbles from the screen
    @objc func deleteRandomBubbles() {
        let numberOfBubblesToDelete = randomBubbleCountToDelete()
        removeBubbles(count: numberOfBubblesToDelete)
    }

    //Count number of bubbles to delete
    func randomBubbleCountToDelete() -> Int {
        return Int.random(in: 0...totalBubbles)
    }

    //after count, just remove it
    func removeBubbles(count: Int) {
        for _ in 0..<count {
            if let randomBubble = self.view.subviews.compactMap({ $0 as? Bubble }).randomElement() {
                randomBubble.removeFromSuperview()
            }
        }
    }

    // Check that new bubbles do not overlap with existing bubbles
    func checkBubblesOverlapped(newBubble: Bubble) -> Bool {
        for subview in self.view.subviews {
            if let existingBubble = subview as? Bubble {
                if newBubble.frame.intersects(existingBubble.frame) {
                    return true
                }
            }
        }
        return false
    }

    // Start to cout from user setting time
    func startCounting() {
        remainingTime -= 1
        // Adjust the bubble generation interval according to the remaining time
        if remainingTime <= 20 {
            bubbleGenerationTime = 0.75
        } else if remainingTime <= 10 {
            bubbleGenerationTime = 0.25
        }

        // When the remaining time is less than or equal to 10 seconds
        //set the colour of the countdown label to red
        if remainingTime <= 10 {
            remainingTimeLabel.textColor = UIColor.red
        }
        remainingTimeLabel.text = String(remainingTime)
        // When the time runs out, end the game
        if remainingTime == 0 {
            timer.invalidate()
            bubbleTimer.invalidate()
            disableBubbles()
            initialCountdownLabel.text = "Game Over!"
            initialCountdownLabel.isHidden = false

            // Update high scores
            let currentHighScore = UserDefaults.standard.integer(forKey: "highScore")
            if bubbleScore > currentHighScore {
                UserDefaults.standard.set(bubbleScore, forKey: "highScore")
            }
            // Updating the leaderboard
            if let playerName = name {
                var leaderboard = UserDefaults.standard.dictionary(forKey: "leaderboard") as? [String: Int] ?? [String: Int]()
                leaderboard[playerName] = bubbleScore
                UserDefaults.standard.set(leaderboard, forKey: "leaderboard")
            }
            // Jump to the high score page
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let highScoreVC = self.storyboard?.instantiateViewController(withIdentifier: "HighScoreViewController") as! HighScoreViewController
                self.navigationController?.pushViewController(highScoreVC, animated: true)
            }
        }
    }

    // Disable user interaction for all bubbles
    func disableBubbles() {
        for subview in self.view.subviews {
            if let bubble = subview as? Bubble {
                bubble.isUserInteractionEnabled = false
            }
        }
    }

    // Create bubbles and add them to the view
    @objc func generateBubble() {
        let bubble = Bubble(remainingTime: remainingTime)
        if !checkBubblesOverlapped(newBubble: bubble) {
            bubble.addTarget(self, action: #selector(bubbleClicked), for: .touchUpInside)
            self.view.addSubview(bubble)
            bubble.bubbleAnimation(duration: 0.6)
        }
    }

    // Create a specified number of bubbles
    func generateMultipleBubbles(numberOfBubbles: Int) {
        for _ in 0..<numberOfBubbles {
            generateBubble()
        }
    }

    // Number of consecutive clicks
    var consecutiveClicks = 0
    @objc func bubbleClicked(_ sender: Bubble) {
        sender.performTapAnimation()
        let scoreForClick = calculateScoreForClick(sender)
        updateBubbleScore(with: scoreForClick)
        updateLastClickedBubbleColor(with: sender.color)
        showScoreLabel(for: sender, score: scoreForClick)
    }

    // Calculate the score for a clicked bubble
    func calculateScoreForClick(_ bubble: Bubble) -> Int {
        if let lastColor = lastClickedBubbleColor, lastColor == bubble.color {
            consecutiveClicks += 1
            return consecutiveClicks >= 2 ? Int(round(Double(bubble.value) * 1.5)) : bubble.value
        } else {
            consecutiveClicks = 1
            return bubble.value
        }
    }

    func updateBubbleScore(with score: Int) {
        bubbleScore += score
        BubbleScore.text = String(bubbleScore)
        updateBubbleHighScore()
    }

    func updateBubbleHighScore() {
        let leaderboard = UserDefaults.standard.dictionary(forKey: "leaderboard") as? [String: Int] ?? [String: Int]()
        if leaderboard.isEmpty {
            BubbleHighScore.text = String(bubbleScore)
        }
    }

    func updateLastClickedBubbleColor(with color: UIColor) {
        lastClickedBubbleColor = color
    }

    func showScoreLabel(for bubble: Bubble, score: Int) {
        let scoreLabel = UILabel()
        if consecutiveClicks >= 2, let lastColor = lastClickedBubbleColor, lastColor == bubble.color {
            scoreLabel.text = "+\(score) (x1.5)"
        } else {
            scoreLabel.text = "+\(score)"
        }
        scoreLabel.textColor = bubble.color
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.sizeToFit()
        scoreLabel.center = bubble.center
        self.view.addSubview(scoreLabel)

        animateScoreLabel(scoreLabel)
    }

    // Animate the score label, then hide it from display after it is finished.
    func animateScoreLabel(_ label: UILabel) {
        UIView.animate(withDuration: 1, animations: {
            label.alpha = 0
            label.center.y -= 20
        }) { _ in
            label.removeFromSuperview()
        }
    }

}

