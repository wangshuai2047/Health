//
//  TrendViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class TrendViewController: UIViewController {

    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var fatButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var proteinButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
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

    @IBAction func selectButtonPressed(button: UIButton) {
        
        if button.selected {
            button.selected = false
        }
        else {
            if selectCount() < 2 {
                button.selected = true
            }
        }
    }
    
    func selectCount() -> Int {
        var selectCount: Int = 0
        selectCount += weightButton.selected ? 1 : 0
        selectCount += fatButton.selected ? 1 : 0
        selectCount += muscleButton.selected ? 1 : 0
        selectCount += waterButton.selected ? 1 : 0
        selectCount += proteinButton.selected ? 1 : 0
        return selectCount
    }
}

extension TrendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TrendTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        cell?.textLabel?.text = "\(indexPath.row)"
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
