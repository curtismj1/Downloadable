//
//  ViewController.swift
//  Downloadable
//
//  Created by MJC on 7/18/17.
//  Copyright © 2017 MJC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var downloadArticleButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Download Article", for: .normal)
        b.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadArticle)))
        return b
    }()
    
    lazy var downloadIssueButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Download Issue", for: .normal)
        b.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadIssue)))
        return b
    }()
    
    lazy var downloadTableViewController: DownloadTableViewController = {
        let tv = DownloadTableViewController()
        tv.tableView.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let downloadButtonsView: UIView = UIView()
    
    var articleCount = 1
    var issueCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(downloadButtonsView)
        view.addSubview(downloadTableViewController.tableView)
        
        // Do any additional setup after loading the view, typically from a nib.
        downloadButtonsView.addSubview(downloadArticleButton)
        downloadButtonsView.addSubview(downloadIssueButton)
        
        downloadButtonsView.backgroundColor = UIColor.lightGray
        downloadButtonsView.translatesAutoresizingMaskIntoConstraints = false
        downloadButtonsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        downloadButtonsView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        downloadButtonsView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        downloadButtonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        downloadArticleButton.centerYAnchor.constraint(equalTo: downloadButtonsView.centerYAnchor).isActive = true
        downloadIssueButton.centerYAnchor.constraint(equalTo: downloadButtonsView.centerYAnchor).isActive = true
        
        let padding = view.frame.width / 4
        downloadArticleButton.centerXAnchor.constraint(equalTo: downloadButtonsView.centerXAnchor, constant: -padding).isActive = true
        downloadIssueButton.centerXAnchor.constraint(equalTo: downloadButtonsView.centerXAnchor, constant: padding).isActive = true
        
        downloadTableViewController.tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        downloadTableViewController.tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        downloadTableViewController.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        downloadTableViewController.tableView.bottomAnchor.constraint(equalTo: downloadButtonsView.topAnchor).isActive = true
        
    }
    
    func createArticle() -> Article {
        let article = Article(title: "Article \(articleCount)")
        articleCount += 1
        return article
    }
    
    func createIssue() -> Issue {
        let articles = Array(0...10000).map {_ in
            return createArticle()
        }
        let issue = Issue(articles: articles, title: "Issue \(issueCount)")
        issueCount += 1
        return issue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadArticle() {
        let article = createArticle()
        let item = DownloadManager.sharedInstance.download(article: article)
        downloadTableViewController.add(item: item)
    }
    
    func downloadIssue() {
        let issue = createIssue()
        let item = DownloadManager.sharedInstance.download(issue: issue)
        downloadTableViewController.add(item: item)
    }
    
    
}

