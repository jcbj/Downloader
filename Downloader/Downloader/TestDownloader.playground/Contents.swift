//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//NSURLSession 网络库 - 原生系统送给我们的礼物
//http://swiftcafe.io/2015/12/20/nsurlsession/

//获取简单数据，例如：json
if let url = NSURL(string: "https://httpbin.org/get") {
    NSURLSession.sharedSession().dataTaskWithURL(url){
        data, response, error in
        print(data)
    }.resume()
}

//下载文件，特殊处理：下载进度，断点续传等
if let imageUrl = NSURL(string: "https://httpbin.org/image/png") {
    NSURLSession.sharedSession().downloadTaskWithURL(imageUrl){ location, response, error in
        //location: 文件下载以后临时保存位置的路径
        guard let url = location else { return }
        guard let imageData = NSData(contentsOfURL: url) else { return }
        //拷贝出来永久保存
        guard let image = UIImage(data: imageData) else { return }
        
        dispatch_async(dispatch_get_main_queue()){
            //...
        }
        
    }.resume()
}

//上传操作
if let uploadURL = NSURL(string: "https://httpbin.org/image/png") {
    let request = NSURLRequest(URL: uploadURL)
    let fileURL = NSURL(fileURLWithPath: "pathToUpload")
    
    NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: fileURL){
        data, response, error in
            //...
        }.resume()
}

//NSURLSession.sharedSession()全局共享，功能受限
//defaultSessionConfiguration:默认配置，使用全局缓存，cookie等信息，适合简单数据
//ephemeralSessionConfiguration:隐私模式，不对缓存，cookie，认证信息保存。
//backgroundSessionConfiguration:后台模式，应用切换到后台，还能继续工作

//使用configuration初始化session以后，就不能再修改配置了
if let imageURL = NSURL(string: "https://httpbin.org/image/png") {
    var session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("download"))
    session.downloadTaskWithURL(imageURL).resume()
}

//代理
//1,NSURLSessionDelegate          - 基类：网络最基础的代理方法
//2,NSURLSessionTaskDelegate      - 继承1：任务请求相关的代理方法
//3, NSURLSessionDownloadDelegate - 继承2：下载任务相关的代理方法
//4, NSURLSessionDataDelegate     - 继承2：普通数据任务和上传任务

//检测下载进度
class Downloader: NSObject, NSURLSessionDownloadDelegate {
    var session: NSURLSession?
    
    override init() {
        super.init()
        
        if let imageURL = NSURL(string: "https://httpbin.org/image/png") {
            session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("task"), delegate: self, delegateQueue: nil)
            session?.downloadTaskWithURL(imageURL).resume()
        }
    }
    
    //下载完成
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("下载完成")
    }
    
    //下载进度
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("正在下载 \(totalBytesWritten) / \(totalBytesExpectedToWrite)")
    }
    
    //下载恢复
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("从\(fileOffset)处恢复下载，共\(expectedTotalBytes)")
    }
}









