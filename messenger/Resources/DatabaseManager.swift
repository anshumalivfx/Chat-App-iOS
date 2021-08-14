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
    
    static func safeEmail(emailAddress: String) -> String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "dot")
        safeEmail.replacingOccurrences(of: "@", with: "-at-")
        return safeEmail
    }
    
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
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to Database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    ///append to user dictionary
                    let newElement =
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.emailAddress
                        ]
                    
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    ///create that array
                    let newCollection : [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.emailAddress
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            
        })
    }
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    public enum DatabaseErrors: Error {
        case failedToFetch
    }
}


// Sending Messages / Conversation
extension DatabaseManager {
    
    
    /// create a new conversations
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
    }
    /// fetching all conversations
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    /// Get All messages of given converstion
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void){
        
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
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
