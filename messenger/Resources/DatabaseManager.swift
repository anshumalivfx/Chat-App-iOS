//
//  DatabaseManager.swift
//  messenger
//
//  Created by Anshumali Karna on 07/08/21.
//

import Foundation
import FirebaseDatabase



final class DatabaseManager {
   static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    
}

// Account management

extension DatabaseManager {
    
    
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        let safeEmail = email.replacingOccurrences(of: ".", with: "dot")
        safeEmail.replacingOccurrences(of: "@", with: "-at-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "dot")
        safeEmail.replacingOccurrences(of: "@", with: "-at-")
        return safeEmail
    }
//    let profilePicture: String
}
