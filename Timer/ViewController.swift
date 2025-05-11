import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    var timer: Timer!
    var countdown: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var inputview: UITextField!
    
    //MARK: -  タイマーの処理
    
    /// タイマーを開始する関数
    /// - Parameter time: 設定する時間（秒）
    func startTimer(time: Int) {
        // もしタイマーが動いていたら止める
        if timer != nil {
            timer.invalidate()
        }
        
        countdown = time
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
    }
    
    /// タイマーによって1秒ごとに呼ばれる関数
    @objc func onTimerCalled() {
        updateLabel()
        updateCountdown()
        
        if isTimeOver() {
            finishTimer()
        }
    }
    
    /// ラベルを更新する
    func updateLabel() {
        let remainingMinutes: Int = countdown / 60
        let remainingSeconds: Int = countdown % 60
        label.text = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
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

    // MARK: - ボタンの処理
    
    @IBAction func select30seconds() {
        startTimer(time: 30)
    }

    @IBAction func select1minute() {
        startTimer(time: 60)
    }
    
    @IBAction func select5minutes() {
        startTimer(time: 300)
    }
    
    @IBAction func select10minutes() {
        startTimer(time: 600)
    }
    @IBAction func selectcustom(){
        let time = Int(inputview.text ?? "0") ?? 0
        startTimer(time:time)
    }
}

