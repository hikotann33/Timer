//
//  TimerViewController.swift
//  Timer
//
//  Created by 村上英明 on 2025/05/11.
//

import UIKit

class TimerViewController: UIViewController {
    var timer: Timer!
    var countdown: Int = 0
    var timeViewHour : String?
    var timeViewmini : String?
    var timeSubject: String?
    
    func startTimer(hour: Int, minute: Int) {
        
        // もしタイマーが動いていたら止める
        if timer != nil {
            timer.invalidate()
        }
        let time: Int = hour * 3600 + minute * 60
        countdown = time
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
    }
    
    /// タイマーによって1分ごとに呼ばれる関数
    @objc func onTimerCalled() {
        updateLabel()
        updateCountdown()
        
        if isTimeOver() {
            finishTimer()
        }
    }
    
    /// ラベルを更新する
    func updateLabel() {
        let remainingminiture: Int = countdown % 60
        let remainingMinutes: Int = countdown / 60
        let remainingSeconds: Int = countdown % 60
        timelabel.text = String(format: "%02d:%02d:%02d", remainingminiture,remainingMinutes, remainingSeconds)
    }
    
    /// 残り時間を更新する
    func updateCountdown() {
        countdown -= 1
    }
    
    /// 残り時間が0かどうか判定する
    /// - Returns: true: 0になった, false: 0より大きい
    func isTimeOver() -> Bool {
        return countdown < 0
    }
    
    /// タイマー終了時の処理
    func finishTimer() {
        timer.invalidate()
        
        let stopAlert = UIAlertController(title: "タイマーが終了しました", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        stopAlert.addAction(okAction)
        present(stopAlert, animated: true)
    }
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var timeViewsubject: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let minute = Int(timeViewmini ?? "0") ?? 0
        let hour = Int(timeViewHour ?? "0") ?? 0
        print(timeViewHour ,"hour")
        
        startTimer(hour: hour, minute: minute)
        timeViewsubject.text = timeSubject
    }
}
