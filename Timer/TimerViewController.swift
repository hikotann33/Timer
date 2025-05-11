//
//  TimerViewController.swift
//  Timer
//
//  Created by 村上英明 on 2025/05/11.
//

import UIKit

class TimerViewController: UIViewController {
    var timeViewHour : String?
    var timeViewmini : String?
    var timeSubject: String?
    
    @IBOutlet weak var timeViewHourLabel: UILabel!
    @IBOutlet weak var timeViewminiLabel: UILabel!
    @IBOutlet weak var timeViewsubject: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(timeViewHour, "bbbbbb")
        timeViewHourLabel.text = timeViewHour
        timeViewminiLabel.text = timeViewmini
        timeViewsubject.text = timeSubject
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
