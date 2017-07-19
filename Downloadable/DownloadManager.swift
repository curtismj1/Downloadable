//
//  DownloadManager.swift
//  Downloadable
//
//  Created by MJC on 7/18/17.
//  Copyright © 2017 MJC. All rights reserved.
//

import Foundation

protocol Downloadable {
    func download(callback: (() -> ())?)
    func halt()
    func contains(item: Downloadable) -> Bool
    var id: String { get }
    func getStatus() -> Float
}

class Article {
    var title: String = ""
    init(title: String) {
        self.title = title
    }
}
class Issue {
    var articles: [Article] = []
    let title: String
    init(articles: [Article], title: String) {
        self.articles = articles
        self.title = title
    }
}

class DownloadManager {
    
    var downloadStack: [Downloadable] = []
    
    static let sharedInstance = DownloadManager()
    
    func halt() {
        
    }
    
    func download(article: Article) -> Downloadable {
        let item = DownloadArticle(article: article)
        append(item: item)
        return item
    }
    
    func download(issue: Issue) -> Downloadable {
        let item = DownloadIssue(issue: issue)
        append(item: item)
        return item
    }
    
    private func append(item: Downloadable) {

            self.downloadStack.last?.halt()
            item.download(callback: {
                self.download()
            })
            self.downloadStack.append(item)
        
    }
    private func download() {

            self.downloadStack.popLast()
            self.downloadStack.last?.download(callback: {
                self.download()
            })
        
    }
}
let updatedDownload = "DOWNLOAD_STATUS_UPDATED"
class DownloadArticle: Downloadable {
    
    var id: String {
        return article.title
    }
    
    func contains(item: Downloadable) -> Bool {
        return false
    }
    
    var progress = 0
    var finishedInt: Int = Int(arc4random()) % 25 + 50
    let article: Article
    init(article: Article) {
        self.article = article
    }
    
    var callBack: (() -> ())?
    
    lazy var timer: Timer = {
        return self.getTimer()
    }()
    
    private func getTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true,
                                    block: { (timer) in
                                        self.progress += 10
                                        if self.progress > self.finishedInt {
                                            timer.invalidate()
                                            self.callBack?()
                                        }
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: updatedDownload), object: self, userInfo: nil))
        }
        )
    }
    
    func download(callback: (() -> ())?) {
        timer = getTimer()
        timer.fire()
        callBack = callback
    }
    
    func halt() {
        timer.invalidate()
    }
    
    func getStatus() -> Float {
        return Float(progress)/Float(finishedInt)
    }
}

class DownloadIssue: Downloadable {
    
    func getStatus() -> Float {
        return Float(progress)/Float(finishedInt)
    }
    
    var id: String {
        return issue.title
    }
    
    func contains(item: Downloadable) -> Bool {
        return articleIndexDictionary[item.id] != nil
    }

    var finishedInt = 0
    var progress = 0
    var isHalted = false
    
    let issue: Issue
    
    private var addOffset = false
    var articleIndexDictionary: [String: Int] = [:]
    
    private var _currentSelectedIndex = 0
    var currentSelectedIndex: Int {
        get {
            return _currentSelectedIndex
        }
        set {
            if newValue != _currentSelectedIndex {
                _currentSelectedIndex = newValue
                offset = 0
                currentDownloadingIndex = newValue
            }
        }
    }
    private var currentDownloadingIndex = 0
    
    func updateDownloadingIndex() {
        if currentDownloadingIndex < currentSelectedIndex {
            currentDownloadingIndex = currentSelectedIndex + self.offset - 1
        } else {
            currentDownloadingIndex = self.currentSelectedIndex - self.offset
            self.offset += 1
        }
        print(currentDownloadingIndex)
    }
    
    var offset = 0
    var downloadArticles: [Downloadable] = []
    var previousArticleProgress = 0
    
    init(issue: Issue) {
        self.issue = issue
        for (index, article) in issue.articles.enumerated() {
            let downloadArticle = DownloadArticle(article: article)
            progress += downloadArticle.progress
            finishedInt += downloadArticle.finishedInt
            downloadArticles.append(downloadArticle)
            articleIndexDictionary[downloadArticle.id] = index
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: updatedDownload), object: downloadArticle, queue: nil, using: { (notification) in
                guard let articleObject = notification.object as? DownloadArticle else {
                    return
                }
                self.progress += {
                    if self.previousArticleProgress > articleObject.progress {
                        return articleObject.progress
                    } else {
                        return articleObject.progress - self.previousArticleProgress
                    }
                }()
                self.previousArticleProgress = articleObject.progress
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: updatedDownload), object: self)
            })

        }
    }
    
    func download(callback: (() -> ())?) {
        updateDownloadingIndex()
        if currentDownloadingIndex >= 0 && currentDownloadingIndex < downloadArticles.count {
            downloadArticles[currentDownloadingIndex].download(callback: {
                return self.download(callback: callback)
            })
        } else {
            if currentSelectedIndex + offset >= downloadArticles.count && currentSelectedIndex - offset < 0 {
                callback?()
                return
            }
            return download(callback: callback)
        }
    }
    
    func halt() {
        isHalted = true
    }
}
