//
//  TimestopCountroller.swift
//  Timer
//
//  Created by murakamihideaki on 2025/08/27.
//

import UIKit

class TimestopController: UIViewController {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var StudyTimeLabel: UILabel!
    @IBOutlet weak var backButtan: UILabel!
    @IBAction func backToFirstScreen(senter: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    var subject: String?
    var studiedHours: Int?
    var studiedMinutes: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayStudyRecord()
        
        func displayStudyRecord() {
            
            let subjectName = subject ?? "勉強"
            
            var timeMessage = ""
            if studiedHours! > 0 {
                timeMessage = "\\(subjectName)を\\(studiedHours)時間\\(studiedMinute)分勉強しました"
            } else {
                timeMessage = "\\(subjectName)を\\(studiedMinute)分勉強しました"
            }
            if subjectLabel != nil {
                subjectLabel.text = subjectName
            }
            if StudyTimeLabel != nil {
                StudyTimeLabel.text = timeMessage
            }
            
        }
    }
}
