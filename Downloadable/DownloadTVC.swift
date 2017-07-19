//
//  DownloadTVC.swift
//  Downloadable
//
//  Created by MJC on 7/18/17.
//  Copyright © 2017 MJC. All rights reserved.
//

import Foundation
import UIKit

class DownloadTableViewController: UITableViewController {
    fileprivate var dataSource: [Downloadable] = []
    
    func add(item: Downloadable) {
        dataSource.insert(item, at: 0)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: updatedDownload), object: item, queue: nil, using: { _ in
            self.tableView.reloadData()
        })
        tableView.reloadData()
    }
    func add(items: [Downloadable]) {
        for item in items {
            dataSource.append(item)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: updatedDownload), object: item, queue: nil, using: { _ in
                self.tableView.reloadData()
            })
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let newView = UIView()
        let downloadObject = dataSource[indexPath.row]
        cell.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.backgroundColor = .green
        newView.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
        newView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        newView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        newView.widthAnchor.constraint(equalToConstant: CGFloat(downloadObject.getStatus()) * cell.frame.width).isActive = true
        newView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        let label = UILabel()
        label.text = dataSource[indexPath.row].id
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let downloadObject = dataSource[indexPath.row] as? DownloadIssue {
            let vc = IssueTVC(downloadIssue: downloadObject)
            vc.add(items: downloadObject.downloadArticles)
            self.present(vc, animated: true, completion: nil)
        }
    }
}

class IssueTVC: DownloadTableViewController {
    let downloadIssue: DownloadIssue
    init(downloadIssue: DownloadIssue) {
        self.downloadIssue = downloadIssue
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let downloadObject = dataSource[indexPath.row] as? DownloadArticle {
            if let index = downloadIssue.articleIndexDictionary[downloadObject.id] {
                downloadIssue.currentSelectedIndex = index
            }
        }
    }
}
