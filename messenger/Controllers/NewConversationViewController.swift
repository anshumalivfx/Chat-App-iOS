//
//  NewConversationViewController.swift
//  messenger
//
//  Created by Anshumali Karna on 06/08/21.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
        
    private let searchBar : UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search For Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultLabel: UILabel = {
       let label = UILabel()
        label.text = "No results found you idiot.."
        label.textAlignment = .center
        label.textColor = .red
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
