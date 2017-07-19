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
        downloadStack.last?.halt()
        item.download(callback: {
            self.download()
        })
        downloadStack.append(item)
    }
    private func download() {
        downloadStack.popLast()
        downloadStack.last?.download(callback: {
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
        return Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true,
            block: { (timer) in
                self.progress += 1
                if self.progress > self.finishedInt {
                    timer.invalidate()
                    self.callBack?()
                }
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: updatedDownload), object: self, userInfo: nil))
            }
        )
    }()
    
    func download(callback: (() -> ())?) {
        timer.fire()
        callBack = callback
    }
    
    func halt() {
        timer.invalidate()
    }
}

class DownloadIssue: Downloadable {
    
    var id: String {
        return issue.title
    }
    
    func contains(item: Downloadable) -> Bool {
        return articleIndexDictionary[item.id] != nil
    }

    let issue: Issue
    private var addOffset = false
    var articleIndexDictionary: [String: Int] = [:]
    
    private var _currentSelectedIndex = 0
    var currentSelectedIndex: Int {
        get {
            return _currentSelectedIndex
        }
        set {
            _currentSelectedIndex = newValue
            offset = 0
            updateDownloadingIndex()
        }
    }
    private var currentDownloadingIndex = 0
    
    func updateDownloadingIndex() {
        if currentDownloadingIndex < currentSelectedIndex {
            currentDownloadingIndex = currentSelectedIndex + self.offset
        } else {
            currentDownloadingIndex = self.currentSelectedIndex - self.offset
            self.offset += 1
        }
    }
    
    
    var offset = 0
    var downloadArticles: [Downloadable] = []
    
    init(issue: Issue) {
        self.issue = issue
        for (index, article) in issue.articles.enumerated() {
            let downloadArticle = DownloadArticle(article: article)
            downloadArticles.append(downloadArticle)
            articleIndexDictionary[downloadArticle.id] = index
        }
        downloadArticles = issue.articles.map {
            return DownloadArticle(article: $0)
        }
    }
    
    func download(callback: (() -> ())?) {
        if currentDownloadingIndex >= 0 && currentDownloadingIndex < downloadArticles.count {
            downloadArticles[currentDownloadingIndex].download(callback: {
                self.updateDownloadingIndex()
                return self.download(callback: callback)
            })
        } else {
            updateDownloadingIndex()
            if currentDownloadingIndex >= 0 && currentDownloadingIndex < downloadArticles.count {
                callback?()
                return
            }
            return download(callback: callback)
        }
    }
    
    func halt() {
        
    }
}
