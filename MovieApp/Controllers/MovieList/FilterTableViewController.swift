//
//  FilterTableViewController.swift
//  MovieApp
//
//  Created by Vishmita Shetty on 03/03/19.
//  Copyright © 2019 Vishmita Shetty. All rights reserved.
//

import UIKit
protocol FilterTableDelegate {
    func passFilterData(selectedIndexPath:IndexPath)
}
class FilterTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var delegate : FilterTableDelegate?
    var filterTableData : [[String: AnyObject]] = []
    @IBOutlet weak var FilterTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.FilterTableView.tableFooterView = UIView()
        FilterTableView.dataSource = self
        FilterTableView.delegate = self
        // Do any additional setup after loading the view.
    }
    //MARK: TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filtercell")
        cell?.textLabel?.text = filterTableData[indexPath.row]["Title"] as? String
        
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.passFilterData(selectedIndexPath: indexPath)
        dismiss(animated: true, completion: nil)
    }
    
    

}
