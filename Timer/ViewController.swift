import UIKit

class ViewController: UIViewController {

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
            }
        }
}

