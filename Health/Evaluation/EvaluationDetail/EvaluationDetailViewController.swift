//
//  EvaluationDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/27.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationDetailViewController: UIViewController {

    var dataId: String?
    
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet var detailView: UIView!
    var widthConstraint: NSLayoutConstraint?
    
    convenience init() {
        self.init(nibName: "EvaluationDetailViewController", bundle: nil)
    }
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initWithDetailView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        widthConstraint?.constant = backgroundScrollView.frame.size.width
        
        //为了兼容iOS7，http://stackoverflow.com/questions/15490140/auto-layout-error
        //iOS8下无需这句话
        self.view.layoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        backgroundScrollView.contentSize = detailView.frame.size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init View
    func initWithDetailView() {
        backgroundScrollView.addSubview(detailView)
        
        backgroundScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // top
        backgroundScrollView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: backgroundScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
        // left
        backgroundScrollView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: backgroundScrollView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        // right
        backgroundScrollView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: backgroundScrollView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
        
        // detail.width
        widthConstraint = NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: backgroundScrollView.frame.size.width)
        detailView.addConstraint(widthConstraint!)
        
        // detail.height
        detailView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 1074))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
