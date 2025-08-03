import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var subjectmaru: UIView!
    @IBOutlet weak var timecoute: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // --- ここで初期設定を全て行います ---
        
        // キーボードの種類を数字パッドに設定
        hourTextField.keyboardType = .numberPad
        minuteTextField.keyboardType = .numberPad
        
        // ボタンの文字色を黒に設定
        startButton.setTitleColor(UIColor.black, for: .normal)
        
        // 画面タップでキーボードを閉じるジェスチャーを追加
        setupDismissKeyboardGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // --- ここでレイアウトが確定した後のデザイン調整を行います ---
        
        // subjectmaru を円形にして、黒い枠線を追加
        subjectmaru.layer.cornerRadius = subjectmaru.frame.height / 2
        subjectmaru.layer.masksToBounds = true
        subjectmaru.layer.borderWidth = 2
        subjectmaru.layer.borderColor = UIColor.black.cgColor
        
        // startButton を角丸にして、黒い枠線を追加
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.masksToBounds = true
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.black.cgColor
        
        // timecoute の角を丸くして、黒い枠線を追加
        timecoute.layer.cornerRadius = subjectmaru.frame.height / 2
        timecoute.layer.masksToBounds = true
        timecoute.layer.borderWidth = 2
        timecoute.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Keyboard Dismissal
    
    // 画面タップでキーボードを閉じるためのメソッド
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Segue Preparation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // セグエの識別子が "totimerview" であることを確認
        if segue.identifier == "totimerview" {
            // 遷移先のViewControllerが TimerViewController であることを確認し、取得
            guard let timerViewController = segue.destination as? TimerViewController else {
                print("エラー: 遷移先が TimerViewController ではありませんでした。")
                return
            }
            
            // 時、分、教科書名のテキストフィールドから値を取得し、前後の空白を削除
            let hourText = hourTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let minuteText = minuteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let subjectText = subjectTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // MARK: - 入力値のバリデーション
            
            // 時の入力チェック
            if hourText.isEmpty || !hourText.isNumberOnly {
                showAlert(title: "入力エラー", message: "時間を正しく入力してください。")
                return
            }
            // 分の入力チェック
            if minuteText.isEmpty || !minuteText.isNumberOnly {
                showAlert(title: "入力エラー", message: "分を正しく入力してください。")
                return
            }
            // 教科書名の入力チェック
            if subjectText.isEmpty {
                showAlert(title: "入力エラー", message: "教科書名を入力してください。")
                return
            }
            
            // 取得した文字列をInt型に変換//
            let hour = Int(hourText) ?? 0
            let minute = Int(minuteText) ?? 0
            
            // 入力値の範囲チェック
            if minute < 0 || minute >= 60 {
                showAlert(title: "入力エラー", message: "分は0から59の間で入力してください。")
                return
            }
            if hour < 0 {
                showAlert(title: "入力エラー", message: "時間は0以上で入力してください。")
                return
            }
            
            // バリデーションが成功した場合、遷移先のTimerViewControllerに値を渡す
            timerViewController.timeViewHour = hourText
            timerViewController.timeViewmini = minuteText
            timerViewController.timeSubject = subjectText
        }
    }
    
    // MARK: - Helper Methods
    
    // アラートを表示するためのヘルパーメソッド
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - String Extension

// Stringの拡張: 文字列が数字のみで構成されているかチェックするプロパティ
extension String {
    var isNumberOnly: Bool {
        return !isEmpty && allSatisfy { $0.isNumber }
    }
}
