//
//  FirstViewController.swift
//  Downloader
//
//  Created by jiangchao on 15/12/24.
//  Copyright © 2015年 jiangchao. All rights reserved.
//

import UIKit

class DownloadTaskCell: UITableViewCell {
    var labelName: UILabel = UILabel()
    var labelSize: UILabel = UILabel()
    var labelProgress: UILabel = UILabel()
    var downloadTask: DownloadTask?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(labelName)
        self.addSubview(labelSize)
        self.addSubview(labelProgress)
        
        self.labelName.font = UIFont.systemFontOfSize(14)
        self.labelSize.font = UIFont.systemFontOfSize(14)
        self.labelProgress.font = UIFont.systemFontOfSize(14)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateProgress:"), name: DownloadTaskNotification.Progress.rawValue, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.labelName.frame = CGRectMake(20, 10, self.contentView.frame.size.width - 50, 20)
        self.labelSize.frame = CGRectMake(20, 40, self.contentView.frame.size.width - 50, 20)
        self.labelProgress.frame = CGRectMake(self.contentView.frame.size.width - 45, 20, 40, 30)
    }
    
    func updateProgress(notification: NSNotification) {
        guard let info = notification.object as? NSDictionary else { return }
        
        if let taskIdentifier = info["taskIdentifier"] as? NSNumber {
            if taskIdentifier.integerValue == self.downloadTask?.taskIdentifier {
                guard let written = info["totalBytesWritten"] as? NSNumber else { return }
                guard let total = info["totalBytesExpectedToWrite"] as? NSNumber else { return }
                
                let formattedWrittenSize = NSByteCountFormatter
                .stringFromByteCount(written.longLongValue, countStyle: NSByteCountFormatterCountStyle.File)
                let formattedTotalSize = NSByteCountFormatter.stringFromByteCount(total.longLongValue, countStyle: NSByteCountFormatterCountStyle.File)
                
                self.labelSize.text = "\(formattedWrittenSize) / \(formattedTotalSize)"
                let percentage = Int((written.doubleValue / total.doubleValue) * 100.0)
                self.labelProgress.text = "\(percentage)%"
            }
        }
    }
    
    func updateData(task: DownloadTask) {
        self.downloadTask = task
        labelName.text = self.downloadTask?.url.lastPathComponent
    }
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private var mainTableView: UITableView?
    private var taskList: [DownloadTask]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "正在下载"
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addTask"))
        
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

    func addTask() {
        let viewController = NewTaskViewController()
        let navController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func reloadData() {
        taskList = TaskManager.shareInstance.unFinishedTask()
        self.mainTableView?.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList == nil ? 0 : self.taskList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? DownloadTaskCell
        if cell == nil {
            cell = DownloadTaskCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        cell?.updateData((self.taskList?[indexPath.row])!)
        return cell!
    }

}

