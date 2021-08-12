//
//  StorageManager.swift
//  messenger
//
//  Created by Anshumali Karna on 12/08/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    /// Uploads picture to Firebase
    public func uploadProfilePicture(with data: Data, fileName: String,completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("Failed to Upload data to Firebase")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("")
                    completion(.failure(StorageError.failedToUpload))
                    return
                }
            })
        })
    }
    
    public enum StorageError: Error {
        case failedToUpload
        case failedToDownload
    }
}
