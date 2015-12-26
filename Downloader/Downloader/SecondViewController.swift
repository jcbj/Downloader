//
//  SecondViewController.swift
//  Downloader
//
//  Created by jiangchao on 15/12/24.
//  Copyright © 2015年 jiangchao. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var mainTableView: UITableView?
    private var taskList: [DownloadTask]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "下载完成"
        self.navigationController?.navigationBar.translucent = false
        
        self.mainTableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.mainTableView?.delegate = self
        self.mainTableView?.dataSource = self
        self.view.addSubview(self.mainTableView!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadData"), name: DownloadTaskNotification.Finish.rawValue, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.reloadData()
    }
    
    func reloadData() {
        self.taskList = TaskManager.shareInstance.finishedTask()
        self.mainTableView?.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList == nil ? 0 : self.taskList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FinishedCell") as? DownloadTaskCell
        
        if cell == nil {
            cell = DownloadTaskCell(style: UITableViewCellStyle.Default, reuseIdentifier: "FinishedCell")
        }
        
        cell?.updateData(self.taskList![indexPath.row])
        
        return cell!
    }


}

