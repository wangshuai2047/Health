//
//  EvaluationPhysiqueDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/9/11.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationPhysiqueDetailViewController: UIViewController {
    
    var physique: Physique?
    
    let selectedColor = UIColor(red: 0, green: 64/255.0, blue: 128/255.0, alpha: 1)
    let selectedFemailColor = UIColor(red: 215/255.0, green: 148/255.0, blue: 239/255.0, alpha: 1)
    
    let cellId = "EvaluationPhysiqueDetailCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    convenience init() {
        self.init(nibName: "EvaluationPhysiqueDetailViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        refreshView()
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func physiqueButtonPressed(sender: UIButton) {
        let physique = Physique(rawValue: sender.tag)
        EvaluationPhysiqueIntroduceViewController.showEvaluationPhysiqueIntroduceViewController(physique!.description, introduce: physique!.detailDescription, rootController: self)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension EvaluationPhysiqueDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! EvaluationPhysiqueDetailCell
        
        // 第一列
        var physique = Physique(rawValue: indexPath.row * 3 + 1)
        cell.titleLabel1.text = physique?.description
        cell.titleLabel1.textColor = UserManager.shareInstance().currentUser.gender ? selectedColor : selectedFemailColor
        cell.physiqueImageView1.image = UIImage(named: physique!.imageName(UserManager.shareInstance().currentUser.gender))
        cell.physiqueButton1.addTarget(self, action: #selector(EvaluationPhysiqueDetailViewController.physiqueButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.physiqueButton1.tag = physique!.rawValue
        
        if physique == self.physique {
            cell.physiqueImageView1.image = UIImage(named: physique!.selectedImageName(UserManager.shareInstance().currentUser.gender))
        }
        
        // 第二列
        physique = Physique(rawValue: indexPath.row * 3 + 2)
        cell.titleLabel2.text = physique?.description
        cell.titleLabel2.textColor = UserManager.shareInstance().currentUser.gender ? selectedColor : selectedFemailColor
        cell.physiqueImageView2.image = UIImage(named: physique!.imageName(UserManager.shareInstance().currentUser.gender))
        cell.physiqueButton2.addTarget(self, action: #selector(EvaluationPhysiqueDetailViewController.physiqueButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.physiqueButton2.tag = physique!.rawValue
        
        if physique == self.physique {
            cell.physiqueImageView2.image = UIImage(named: physique!.selectedImageName(UserManager.shareInstance().currentUser.gender))
        }
        
        // 第三列
        physique = Physique(rawValue: indexPath.row * 3 + 3)
        cell.titleLabel3.text = physique?.description
        cell.titleLabel3.textColor = UserManager.shareInstance().currentUser.gender ? selectedColor : selectedFemailColor
        cell.physiqueImageView3.image = UIImage(named: physique!.imageName(UserManager.shareInstance().currentUser.gender))
        cell.physiqueButton3.addTarget(self, action: #selector(EvaluationPhysiqueDetailViewController.physiqueButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.physiqueButton3.tag = physique!.rawValue
        
        if physique == self.physique {
            cell.physiqueImageView3.image = UIImage(named: physique!.selectedImageName(UserManager.shareInstance().currentUser.gender))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.height / 3
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let deCell = cell as? EvaluationPhysiqueDetailCell {
            deCell.physiqueButton1.removeTarget(self, action: #selector(EvaluationPhysiqueDetailViewController.physiqueButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            deCell.physiqueButton2.removeTarget(self, action: #selector(EvaluationPhysiqueDetailViewController.physiqueButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            deCell.physiqueButton3.removeTarget(self, action: #selector(EvaluationPhysiqueDetailViewController.physiqueButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
}
