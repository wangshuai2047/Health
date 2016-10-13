//
//  FeedBackViewController.swift
//  Health
//
//  Created by Yalin on 15/10/7.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class FeedBackViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    fileprivate let cellId = "FeedbackCell"
    
    var feedbacks: [(time: String, feedback: String)] = []
    
    // MARK: - Life Cycle
    deinit {
        // perform the deinitialization
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    convenience init() {
        self.init(nibName: "FeedBackViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let keyboardShowSelector: Selector = "keyboardShow:"
        let keyboardHideSelector: Selector = "keyboardHide:"
        NotificationCenter.default.addObserver(self, selector: keyboardShowSelector, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: keyboardHideSelector, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        SettingManager.sendFeedBack(textView.text) {[unowned self] (error) -> Void in
            if error == nil {
                self.feedbacks.append((Date().currentZoneFormatDescription(), self.textView.text))
                self.textView.resignFirstResponder()
                self.textView.text = ""
                self.tableView.reloadData()
            }
            else {
                Alert.showErrorAlert("发送错误", message: error?.localizedDescription)
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - KeyboardNotification
    func keyboardShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo;
        let animationDuration: TimeInterval  = TimeInterval((info![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue)
        let keyboardFrame: CGRect = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        viewBottomConstraint.constant = keyboardFrame.size.height
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardHide(_ notification: Notification) {
        
        viewBottomConstraint.constant = 0
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

extension FeedBackViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FeedbackCell
        
        let feedBack = feedbacks[(indexPath as NSIndexPath).row]
        
        cell.timeLabel.text = feedBack.time
        cell.feedbackLabel.text = feedBack.feedback
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let feedBack = feedbacks[(indexPath as NSIndexPath).row]
        
        let feedBackSize = NSString(string: feedBack.feedback).boundingRect(with: CGSize(width: tableView.frame.size.width - 16, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)], context: nil)
        
        return feedBackSize.height + 144 - 90.5
    }
}
