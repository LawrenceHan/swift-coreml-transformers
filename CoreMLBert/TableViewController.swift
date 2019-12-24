//
//  TableViewController.swift
//  CoreMLBert
//
//  Created by han guang on 2019/12/24.
//  Copyright © 2019 Hugging Face. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var qaObject: QAObject!
    var selectedIndexPath: IndexPath?
    let m = BertForQuestionAnswering(.distilled)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        qaObject = QAObject.load(from: "qa")
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = selectedIndexPath {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return qaObject.titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return qaObject.titles[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = qaObject.titles[indexPath.section][indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "ViewController")  as? ViewController else { return }
        vc.m = m
        vc.subjects = qaObject.contents[indexPath.section]
        vc.questions = qaObject.questions[indexPath.section]
        selectedIndexPath = indexPath
        navigationController?.pushViewController(vc, animated: true)
    }

}
