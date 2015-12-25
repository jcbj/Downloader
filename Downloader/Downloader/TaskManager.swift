//
//  TaskManager.swift
//  Downloader
//
//  Created by jiangchao on 15/12/24.
//  Copyright © 2015年 jiangchao. All rights reserved.
//

import UIKit

//下载任务
struct DownloadTask {
    
    //当前下载任务url
    var url: NSURL
    //下载成功以后本地临时文件路径
    var localURL: NSURL?
    //此下载任务唯一标示符
    var taskIdentifier: Int
    //是否下载完成
    var finished: Bool = false
    
    init(url: NSURL, taskIdentifier: Int) {
        self.url = url
        self.taskIdentifier = taskIdentifier
    }
}

enum DownloadTaskNotification: String {
    case Progress = "downloadNotificationProgress"
    case Finish = "downloadNotificationFinish"
}

class TaskManager: NSObject, NSURLSessionDownloadDelegate {
    
    private var session: NSURLSession?
    //保存所有的下载任务
    var taskList: [DownloadTask] = [DownloadTask]()
    //单例
    static var shareInstance: TaskManager = TaskManager()

    override init() {
        super.init()
        
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("downloadSession")
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        self.taskList = [DownloadTask]()
        self.loadTaskList()
    }
    
    func unFinishedTask() -> [DownloadTask] {
        return taskList.filter{ task in
            return task.finished == false
        }
    }
    
    func finishedTask() -> [DownloadTask] {
        return taskList.filter { task in
            return task.finished
        }
    }
    
    func saveTaskList() {
        let jsonArray = NSMutableArray()
        
        for task in self.taskList {
            let jsonItem = NSMutableDictionary()
            jsonItem["url"] = task.url.absoluteString
            jsonItem["taskIdentifier"] = NSNumber(long: task.taskIdentifier)
            jsonItem["finished"] = NSNumber(bool: task.finished)

            jsonArray.addObject(jsonItem)
        }
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: NSJSONWritingOptions.PrettyPrinted)
            NSUserDefaults.standardUserDefaults().setObject(jsonData, forKey: "taskList")
            NSUserDefaults.standardUserDefaults().synchronize()
        } catch {
            print("saveTaskList failed")
        }
    }

    func loadTaskList() {
        
        if let jsonData: NSData = NSUserDefaults.standardUserDefaults().objectForKey("taskList") as? NSData {
            
            do {
                guard let jsonArray: NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? NSArray else { return }
                
                for jsonItem in jsonArray {
                    if let item: NSDictionary = jsonItem as? NSDictionary {
                        guard let urlString = item["url"] as? String else { return }
                        guard let taskIdentifier = item["taskIdentifier"]?.longValue else { return }
                        guard let finished = item["finished"]?.boolValue else { return }
                        
                        var downloadTask = DownloadTask(url: NSURL(string: urlString)!, taskIdentifier: taskIdentifier)
                        downloadTask.finished = finished
                        self.taskList.append(downloadTask)
                    }
                }
            } catch {
                
            }
        }
    }
    
    func newTask(url: String) {
        if let url = NSURL(string: url) {
            let downloadTask = self.session?.downloadTaskWithURL(url)
            downloadTask?.resume()
            
            let task = DownloadTask(url: url, taskIdentifier: downloadTask!.taskIdentifier)
            self.taskList.append(task)
            self.saveTaskList()
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var fileName = ""
        
        for var i = 0; i < self.taskList.count; i++ {
            if self.taskList[i].taskIdentifier == downloadTask.taskIdentifier {
                self.taskList[i].finished = true
                fileName = self.taskList[i].url.lastPathComponent!
            }
        }
        
        if let documentURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first {
            
            let destURL = documentURL.URLByAppendingPathComponent(fileName)
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(location, toURL: destURL)
            } catch {
                print("\(fileName) is move failed.")
            }
        }
        
        self.saveTaskList()
        
        NSNotificationCenter.defaultCenter().postNotificationName(DownloadTaskNotification.Finish.rawValue, object: downloadTask.taskIdentifier)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progressInfo = ["taskIdentifier" : downloadTask.taskIdentifier,
                            "totalBytesWritten" : NSNumber(longLong: totalBytesWritten),
            "totalBytesExpectedToWrite" : NSNumber(longLong: totalBytesExpectedToWrite)]
        NSNotificationCenter.defaultCenter().postNotificationName(DownloadTaskNotification.Progress.rawValue, object: progressInfo)
    }    
}
