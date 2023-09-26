//  HighScoreViewController.swift
//  BubbleGame
//  Created by Chenjun Zheng 14208603
//  Language: Swift

import UIKit

// Create a structure to display the game's score.
struct GameScore {
    var userName: String
    var Score: Int
}

// Create a HighScoreview controller
class HighScoreViewController: UIViewController {
    @IBOutlet weak var HomeBtn: UIButton!
    @IBOutlet weak var HighScoreLabel: UILabel!
    @IBOutlet weak var RestarT: UIButton!
    @IBOutlet weak var tableView: UITableView!

    let userDefaults = UserDefaults()
    var namescore = [String: Int]()

    // when the view is loaded is executed
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        // Make the button's click event visible.
        HomeBtn.addTarget(self, action: #selector(homeBtnTapped), for: .touchUpInside)
        RestarT.addTarget(self, action: #selector(clearLeaderboard), for: .touchUpInside)

        // setting up user defaults
        if userDefaults.value(forKey: "playerName") == nil {
            userDefaults.setValue("ANONYMOUS", forKey: "playerName")
        }
        if userDefaults.value(forKey: "leaderboard") != nil {
            namescore = userDefaults.value(forKey: "leaderboard") as! [String: Int]
        }

        // Reload the data after setting the table view's data source.
        tableView.dataSource = self
        tableView.reloadData()
    }

    // HomeBtn function
    @objc func homeBtnTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    // executed when RestarT is clicked
    @objc func clearLeaderboard() {
        namescore.removeAll()
        userDefaults.set(namescore, forKey: "leaderboard")
        tableView.reloadData()
    }
}

// To implement the UITableViewDataSource protocol, extend the HighScoreViewController class.
extension HighScoreViewController: UITableViewDataSource {
    // The amount of rows in the table view is returned.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namescore.count
    }

    // Set the table view's cell contents accordingly.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highScoreCell", for: indexPath)

        // Dictionary conversion to arrays and value sorting
        let sortedArray = namescore.map({ ($0.key, $0.value) }).sorted(by: { $0.1 > $1.1 })

        // Set the cell text
        let (name, score) = sortedArray[indexPath.row]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = String(score)

        return cell
    }
}
