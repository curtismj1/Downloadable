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
    private var dataSource: [Downloadable] = []
    
    func add(item: Downloadable) {
        dataSource.insert(item, at: 0)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: updatedDownload), object: item, queue: nil, using: { _ in
            self.tableView.reloadData()
        })
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if let downloadArticle = dataSource[indexPath.row] as? DownloadArticle {
            let newView = UIView()
            cell.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.backgroundColor = .green
            newView.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            newView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            newView.widthAnchor.constraint(equalToConstant: CGFloat(downloadArticle.progress) / CGFloat(downloadArticle.finishedInt) * cell.frame.width).isActive = true
            newView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        }
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

}
