import UIKit

class ViewController: UIViewController {

<<<<<<< HEAD
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField! // 教科書名入力用のTextField
    @IBOutlet weak var startButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 時と分のテキストフィールドに数字入力専用のキーボードを設定
        hourTextField.keyboardType = .numberPad
        minuteTextField.keyboardType = .numberPad
        
        // 画面タップでキーボードを閉じるジェスチャーを追加
        setupDismissKeyboardGesture()
    }
    
    // MARK: - Keyboard Dismissal

    // 画面タップでキーボードを閉じるためのメソッド
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // これにより、キーボードを閉じつつ、UI要素の操作に影響を与えないようにします。
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
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
=======
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var inputview: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // ②Segueの識別子確認
            if segue.identifier == "totimerview" {
                // ③遷移先ViewCntrollerの取得
                let timerViewController = segue.destination as! TimerViewController
                // ④値の設定
                timerViewController.timeViewHour = hourTextField.text
                timerViewController.timeViewmini = minuteTextField.text
                timerViewController.timeSubject = subjectTextField.text
>>>>>>> 6bea78d6ae30a0a3188c03392f1e75ef097c1be8
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
            
            // 取得した文字列をInt型に変換
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

// Stringの拡張: 文字列が数字のみで構成されているかチェックするプロパティ
extension String {
    var isNumberOnly: Bool {
        return !isEmpty && allSatisfy { $0.isNumber }
    }
}
