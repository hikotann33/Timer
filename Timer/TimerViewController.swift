//
//  TimerViewController.swift
//  Timer
//
//  Created by 村上英明 on 2025/05/11.
//

import UIKit
import AVFoundation
import Vision //画像認識用のシステム

class TimerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var timer: Timer!
    var countdown: Int = 0
    var timeViewHour : String?
    var timeViewmini : String?
    var timeSubject: String?
    
    //カメラの読み取り用のシステム
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //検出用に使用する
    private var classificationRequest: VNClassifyImageRequest! //画像認識システム
    private var isTimerPaused = false
    private var detectedKeyword: String = ""
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var timeViewsubject: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //カメラセッションの追加
        setupCamera()
        setupPhoneDetection()
        
        let hourString = timeViewHour ?? "0"
        let minuteString = timeViewmini ?? "0"
        
        let minute = Int(minuteString) ?? 0
        let hour = Int(hourString) ?? 0
        
        print("Received Hour String: '\(hourString)', Converted Hour: \(hour)")
        print("Received Minute String: '\(minuteString)', Converted Minute: \(minute)")
        
        timeViewsubject.text = timeSubject
        
        startTimer(hour: hour, minute: minute)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    func setupPhoneDetection() {
        // 画像分類リクエストの設定
        classificationRequest = VNClassifyImageRequest { [weak self] request, error in
            if let results = request.results as? [VNClassificationObservation] {
                // resultsには「何が映っているか」の判定結果が入ってくる
                self?.processClassificationResults(results)
            }
        }
    }
    
    // 修正: pauseTier -> pauseTimer, 正しい一時停止処理
    func pauseTimer() {
        isTimerPaused = true
        if timer != nil {
            timer.invalidate()
        }
    }
    
    func processClassificationResults(_ results: [VNClassificationObservation]) {
        //検出するためのセッション
        let phoneKeywords = ["iPhone", "Android", "Windows Phone", "phone", "mobile", "smartphone"]
        
        //上位5つの結果のみを表示する。
        for observation in results.prefix(5) {
            let identifier = observation.identifier.lowercased()
            
            for keyword in phoneKeywords {
                if identifier.contains(keyword.lowercased()) && observation.confidence > 0.2 {  // 0.2 = 20%
                    DispatchQueue.main.async { [weak self] in
                        self?.detectedKeyword = identifier  // デバッグ用に保存
                        self?.handlePhoneDetection()
                    }
                    return // 検出したらすぐ終了
                }
            }
        }
    }
    
    func captrueoutput(_ output: AVCaptureOutput, didoutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([self.classificationRequest])
        } catch {
            print("Error performing classification request: \(error)")
        }
    }
    // 修正: alert変数名とコード構造を修正
    func showPhoneDetectionAlert() {
        let alert = UIAlertController( // 修正: alerrt -> alert
            title: "障害物を検知しました。",
            message: "勉強に集中してください\nタイマーが一時停止されました\n\n検知: \(detectedKeyword)", // 修正: phoneKeywords -> detectedKeyword
            preferredStyle: .alert
        )
        
        //タイマー再開のアクションを作成する。
        let resumeAction = UIAlertAction(title:"タイマー再開", style: .default) { [weak self] _ in
            self?.resumeTimer() //タイマーを再開するコマンド
        }
        
        //タイマーを修了するためのアクション
        let stopAction = UIAlertAction(title: "タイマー終了", style: .destructive) { [weak self] _ in // 修正: 修了 -> 終了
            self?.finishTimer()
        }
        
        alert.addAction(resumeAction)
        alert.addAction(stopAction)
        
        present(alert, animated: true)
    }
    
    // 修正: 重複コードを削除し、シンプルに
    func handlePhoneDetection() {
        if timer != nil && timer.isValid && !isTimerPaused {
            pauseTimer()  // タイマーを一時停止する関数
            showPhoneDetectionAlert()  // アラートを表示する関数
        }
    }
    
    func resumeTimer() {
        isTimerPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
    }
    
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
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("バックカメラが見つかりません")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            // ビデオ出力を追加（画像認識のため）
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            if captureSession?.canAddOutput(videoOutput) == true {
                captureSession?.addOutput(videoOutput)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            //背景レイヤーとして追加
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        } catch {
            print("カメラの初期化でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try imageRequestHandler.perform([classificationRequest])
        } catch {
            print("画像認識でエラーが発生しました: \(error)")
        }
    }
}
