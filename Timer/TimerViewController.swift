//
//  TimerViewController.swift
//  Timer
//
//  Created by 村上英明 on 2025/05/11.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController {
    var timer: Timer!
    var countdown: Int = 0
    var timeViewHour : String?
    var timeViewmini : String?
    var timeSubject: String?
    
    
    
    //カメラ用のシステムを作成
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var timeViewsubject: UILabel!

    func startTimer(hour: Int, minute: Int) {
        
        if timer != nil {
            timer.invalidate()
        }
        
        let totalSeconds: Int = hour * 3600 + minute * 60
        countdown = totalSeconds
        

        print("Calculated totalSeconds: \(totalSeconds)")
        
        if totalSeconds <= 0 {
            print("警告: 設定された時間が0以下です。タイマーを開始しません。")
       
            timelabel.text = "00:00:00"
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
        
        updateLabel()
    }
    
    @objc func onTimerCalled() {
        updateCountdown()
        updateLabel()
        
        if isTimeOver() {
            finishTimer()
        }
    }
    
    func updateLabel() {
        let hours = countdown / 3600
        let minutes = (countdown % 3600) / 60
        let seconds = countdown % 60
        
        timelabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func updateCountdown() {
        countdown -= 1
    }
    
    func isTimeOver() -> Bool {
        return countdown < 0
    }
    
    func finishTimer() {
        timer.invalidate()
        
        let stopAlert = UIAlertController(title: "タイマーが終了しました", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        stopAlert.addAction(okAction)
        present(stopAlert, animated: true)
        
        performSegue(withIdentifier: "toTimestopCountroller", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TimestopController {
            let hourInt = Int(timeViewHour ?? "0") ?? 0
            let minuteInt = Int(timeViewmini ?? "0") ?? 0
            let totalSeconds = hourInt * 3600 + minuteInt * 60
            let studiedSeconds = totalSeconds - countdown

            destinationVC.subject = timeSubject
            destinationVC.studiedHours = studiedSeconds / 3600
            destinationVC.studiedMinutes = (studiedSeconds % 3600) / 60
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession?.stopRunning()
        //カメラセッションの追加
        setupCamera()
        
        let hourString = timeViewHour ?? "0"
        let minuteString = timeViewmini ?? "0"
        
        let minute = Int(minuteString) ?? 0
        let hour = Int(hourString) ?? 0
        
        print("Received Hour String: '\(hourString)', Converted Hour: \(hour)")
        print("Received Minute String: '\(minuteString)', Converted Minute: \(minute)")
        
        timeViewsubject.text = timeSubject
        
        startTimer(hour: hour, minute: minute)
    }
    
    func setupCamera(){
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .medium
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("フロントカメラが見つかりません")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            //背景レイヤーとして追加
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
            
            DispatchQueue.global(qos: .userInitiated).async{
                self.captureSession?.startRunning()
            }
        } catch{
            print("カメラの初期化でエラーが発生しました: \\(error.localizedDescription)")
        }
    }
}
