//
//  ViewController.swift
//  messenger
//
//  Created by Anshumali Karna on 06/08/21.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DatabaseManager.shared.test()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        validateAuth()
        
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }


}

