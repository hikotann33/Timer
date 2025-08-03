//
//  finish_menu.swift
//  Timer
//
//  Created by murakamihideaki on 2025/08/03.
//

import UIKit

class outeletVale :UIViewController {
    
    //storyboardから接続するIBOutlet （三つ必要）
    @IBOutlet weak var subjectLabel: UILabel!  //教科書用
    @IBOutlet weak var studyTimeLabel: UILabel!  //勉強時間表示用
    @IBOutlet weak var backButtan: UIButton!  //戻るボタン用
    
    //前の画面から受け取るデータ（3つ必要）
    var timeSubject: String?  //教科名
    var timeViewHour: Int = 0
    var timeViewmini: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //学習記録を表示
        displayStudyRecord()
    }
    
    func displayStudyRecord() {
        //教科書名を取得する
        let subjectName = subject ?? "勉強"
        
        //時間の表示メッセージを作成
        var timemessage = ""
        if timeViewHour > 0 {
            timemessage = "\(subjectName)を\\(studiedHours)時間\\(studiedMinutes)分頑張りました。"
        } else {
            timemessage = "\\(subjectName)を\\(studiedMinutes)分頑張りました。"
        }
        if subjectLabel != nil {
            
        }
    }
    
    @IBAction func backButton(senter: UIButton) {
        ///最初の戻るもの
        ///全ての画面を閉じる
        self.view.window?.rootViewController?.dismiss(animated:true,completion: nil)
    }
}
