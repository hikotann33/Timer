//
//  TimerViewController.swift
//  Timer
//
//  Created by 村上英明 on 2025/05/11.
//


import UIKit
import AVFoundation
import Vision

class TimerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var timer: Timer!
    var countdown: Int = 0
    var timeViewHour: String?
    var timeViewmini: String?
    var timeSubject: String?
    
    // カメラの読み取り用
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    
    // 検知した時にどうするか
    private var classificationRequest: VNClassifyImageRequest!
    private var isTimerPaused = false
    private var detectedKeyword: String = ""
    
    // 警告機能が重複しないようにする
    private var isAlertShowing = false
    private var lastDetectionTime: Date = Date()
    private let detectionCooldown: TimeInterval = 2.0  // 2秒間のクールダウン
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var timeViewsubject: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        classificationRequest = VNClassifyImageRequest { [weak self] request, error in
            if let results = request.results as? [VNClassificationObservation] {
                self?.processClassificationResults(results)
            }
        }
    }
    
    func pauseTimer() {
        guard !isTimerPaused else { return }
        
        isTimerPaused = true
        if timer != nil && timer.isValid {
            timer.invalidate()
        }
        
        print("タイマーを一時停止しました")
    }
    
    func processClassificationResults(_ results: [VNClassificationObservation]) {
        let now = Date()
        guard now.timeIntervalSince(lastDetectionTime) >= detectionCooldown else {
            return
        }
        
        let phoneKeywords = ["iPhone", "Android", "Windows Phone", "pen", "mobile", "smartphone",]
        
        let uid = UUID().uuidString
        for observation in results {
            print("observation: \(observation)")
            let identifier = observation.identifier.lowercased()
            print(identifier, "id", uid)
            
            for keyword in phoneKeywords {
                if identifier.contains(keyword.lowercased()) && observation.confidence > 0.1 {
                    print("検出物: \(identifier)")
                    lastDetectionTime = now
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.detectedKeyword = identifier
                        self?.handlePhoneDetection()
                    }
                    return
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isAlertShowing && !isTimerPaused else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try imageRequestHandler.perform([classificationRequest])
        } catch {
            print("画像認識でエラーが発生しました: \(error)")
        }
    }
    
    func showPhoneDetectionAlert() {
        guard !isAlertShowing else { return }
        
        isAlertShowing = true
        
        let alert = UIAlertController(
            title: "障害物を検知しました",
            message: "勉強に集中してください\nタイマーが一時停止されました\n\n検知内容: \(detectedKeyword)",
            preferredStyle: .alert
        )
        
        let resumeAction = UIAlertAction(title: "再開", style: .default) { [weak self] _ in
            self?.isAlertShowing = false
            self?.resumeTimer()
        }
        
        let stopAction = UIAlertAction(title: "終了", style: .destructive) { [weak self] _ in
            self?.isAlertShowing = false
            self?.finishTimer()
        }
        
        alert.addAction(resumeAction)
        alert.addAction(stopAction)
        
        present(alert, animated: true)
    }
    
    func handlePhoneDetection() {
        guard timer != nil && timer.isValid && !isTimerPaused && !isAlertShowing else {
            print("停止中です")
            return
        }
        
        print("スマホが検出されました: \(detectedKeyword)")
        pauseTimer()
        showPhoneDetectionAlert()
    }
    
    func resumeTimer() {
        guard isTimerPaused else {
            print("タイマーはすでに開始しています")
            return
        }
        
        isTimerPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
        
        print("再開")
    }
    
    func startTimer(hour: Int, minute: Int) {
        if timer != nil {
            timer.invalidate()
        }
        
        let totalSeconds: Int = hour * 3600 + minute * 60
        countdown = totalSeconds
        
        print("Calculated totalSeconds: \(totalSeconds)")
        
        if totalSeconds <= 0 {
            print("指定された時間を入力してください")
            timelabel.text = "00:00:00"
            return
        }
        
        isTimerPaused = false
        isAlertShowing = false
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
        updateLabel()
        
        print("タイマーを開始しました: \(totalSeconds)秒")
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
        if timer != nil {
            timer.invalidate()
        }
        
        isTimerPaused = true
        
        let stopAlert = UIAlertController(title: "勉強が終了しました", message: "お疲れ様でした", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // 必要に応じて前の画面に戻る処理を追加
//            self?.navigationController?.popViewController(animated: true)
            let nextVC = outeletVale()
            self?.navigationController?.pushViewController(nextVC, animated: true)
        }
        stopAlert.addAction(okAction)
        present(stopAlert, animated: true)
        
        print("タイマーが終了しました")
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
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            if captureSession?.canAddOutput(videoOutput) == true {
                captureSession?.addOutput(videoOutput)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        } catch {
            print("カメラの初期化でエラーが発生しました: \(error.localizedDescription)")
        }
    }
}
