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
    
    private let cellId = "FeedbackCell"
    
    var feedbacks: [(time: String, feedback: String)] = []
    
    // MARK: - Life Cycle
    deinit {
        // perform the deinitialization
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    convenience init() {
        self.init(nibName: "FeedBackViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let keyboardShowSelector: Selector = "keyboardShow:"
        let keyboardHideSelector: Selector = "keyboardHide:"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: keyboardShowSelector, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: keyboardHideSelector, name: UIKeyboardWillHideNotification, object: nil)
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
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
    @IBAction func sendButtonPressed(sender: AnyObject) {
        SettingManager.sendFeedBack(textView.text) {[unowned self] (error) -> Void in
            if error == nil {
                self.feedbacks.append((NSDate().currentZoneFormatDescription(), self.textView.text))
                self.textView.resignFirstResponder()
                self.textView.text = ""
                self.tableView.reloadData()
            }
            else {
                Alert.showErrorAlert("发送错误", message: error?.localizedDescription)
            }
        }
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - KeyboardNotification
    func keyboardShow(notification: NSNotification) {
        let info = notification.userInfo;
        let animationDuration: NSTimeInterval  = NSTimeInterval((info![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue)
        let keyboardFrame: CGRect = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        viewBottomConstraint.constant = keyboardFrame.size.height
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardHide(notification: NSNotification) {
        
        viewBottomConstraint.constant = 0
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

extension FeedBackViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! FeedbackCell
        
        let feedBack = feedbacks[indexPath.row]
        
        cell.timeLabel.text = feedBack.time
        cell.feedbackLabel.text = feedBack.feedback
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let feedBack = feedbacks[indexPath.row]
        
        let feedBackSize = NSString(string: feedBack.feedback).boundingRectWithSize(CGSizeMake(tableView.frame.size.width - 16, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17)], context: nil)
        
        return feedBackSize.height + 144 - 90.5
    }
}
