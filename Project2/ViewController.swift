import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button3: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button1: UIButton!
    
    var countries = [String]()
    var highScore = 0
    var score = 0
    var correctAnswer = 0
    var numberOfQuestions = 0
    var functionsHaveRun = false
    var daysOfTheWeek = [1, 2, 3, 4, 5, 6, 7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !functionsHaveRun {
            registerNotificationRequest()
            scheduleNotifications()
            functionsHaveRun = true
        }
        
        let defaults = UserDefaults.standard
        if let savedScore = defaults.object(forKey: "highScore") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                highScore = try jsonDecoder.decode(Int.self, from: savedScore)
            } catch {
                print("Failed to load data.")
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
        
        countries += ["estonia", "germany", "russia", "france", "uk", "us", "ireland", "italy", "monaco", "nigeria", "poland", "spain"]
        
        askFirstQuestion()
    }
    
    func askFirstQuestion(action: UIAlertAction! = nil) {
        score = 0
        numberOfQuestions = 0
        
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased() + " \(score)"
        numberOfQuestions += 1
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased() + " \(score)"
        numberOfQuestions += 1
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            sender.transform = .identity
        }
        var title: String
        var alertMessage = (10 - numberOfQuestions == 1) ? "\(10 - numberOfQuestions) question remaining" : "\(10 - numberOfQuestions) questions remaining"
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong"
            if score > 0 {
                score -= 1
            }
            alertMessage += "\nThat’s the flag of \(countries[sender.tag].uppercased())"
        }
        
        if numberOfQuestions < 10 {
            let ac = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        } else {
            if score > highScore {
                highScore = score
                saveHighScore()
                alertMessage += "\n New high score: \(highScore)"
            } else {
                alertMessage += "\n Final score: \(score)"
            }
            let ac = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: askFirstQuestion))
            present(ac, animated: true)
        }
    }
    
    @objc func showScore() {
        let ac = UIAlertController(title: "Score", message: "Your score is \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func saveHighScore() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(highScore) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "highScore")
        } else {
            print("Failed to save data.")
        }
    }
    
    func registerNotificationRequest() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Success")
            } else {
                print("Failed")
            }
        }
    }
    
    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        registerCategories()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily reminder"
        content.body = "Come play the game!"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        for day in daysOfTheWeek {
            var dateComponents = DateComponents()
            dateComponents.hour = 12
            dateComponents.minute = 0
            dateComponents.weekday = day
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let open = UNNotificationAction(identifier: "reminder", title: "Open the game", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [open], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        functionsHaveRun = false
        registerNotificationRequest()
        scheduleNotifications()
        completionHandler()
    }
}

