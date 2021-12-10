//
//  ChatViewController.swift
//  messenger
//
//  Created by Anshumali Karna on 11/08/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

struct Message : MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}


extension MessageKind {
    var messageKindString: String {
        switch self {
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender : SenderType {
   public var photoURL: String
   public var senderId: String
   public var displayName: String
}


struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var otherUserEmail: String
    private var conversationId: String
    public var isNewConversation = false
    
    
    private var messages = [Message]()
    
    
    
    private var selfSender: Sender? = {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "",
                senderId: safeEmail,
                displayName: "Me"
                )
        
    }()
    
   
    
    init(with email: String, id: String?) {
        self.conversationId = id ?? "id"
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        setUpInputButton()
    }
    
    
    private func setUpInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.onTouchUpInside({ [weak self] _ in
            self?.presentInputActionSheet()
        })
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "what would you like to Attach?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: {[weak self] _ in
                                                self?.presentPhotoInputActionSheet()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { _ in
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Audio",
                                            style: .default,
                                            handler: { _ in
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach photo from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: {[weak self] _ in
                                                let picker = UIImagePickerController()
                                                picker.sourceType = .camera
                                                picker.delegate = self
                                                picker.allowsEditing = true
                                                self?.present(picker, animated: true)
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Gallery",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                let picker = UIImagePickerController()
                                                picker.sourceType = .photoLibrary
                                                picker.delegate = self
                                                picker.allowsEditing = true
                                                self?.present(picker, animated: true)
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                }
                
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId as? String {
            print(conversationId)
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
}


extension  ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let messageId = createMessageId(), let conversationId = conversationId as? String,
              let imageData = image.pngData(),
              let name =  self.title,
              let selfSender = selfSender
              else {
                return
              }
        let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        // Upload Image
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let urlString):
                // ready to send message
                print("Successfully uploaded photo: \(urlString)")
                
                guard let url = URL(string: urlString),
                      let placeholder = UIImage(systemName: "plus") else {
                    return
                }
                
                let media = Media(url: url,
                                  image: nil,
                                  placeholderImage: placeholder,
                                  size: .zero)
                
                let photomessage = Message(sender: selfSender,
                                      messageId: messageId,
                                      sentDate: Date(),
                                      kind: .photo(media))
                
                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: photomessage, completion: { success in
                    if success {
                        print("Sent Photo Message")
                    }
                    
                    else {
                        print("Failed to send message")
                    }
                })
            case .failure(let error):
                print("Message Upload Error: \(error)")
            }
        })
        // Send Image
        
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId()
        else {
            return
        }
        print("Sending: \(text)")
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        // Send Message
        if isNewConversation{
            // create new convo in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                }
                else {
                    print("Failed to sent")
                }
            })
        }
        
        else {
            guard let conversationId = conversationId as? String, let name = self.title as? String else {
                return
            }
            
            // append
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
        let newIdentifier = "\(otherSafeEmail)_\(safeCurrentEmail)_\(dateString)"
        print("Created Id: \(newIdentifier)")
        
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "1", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
}

// Sending Messages / Conversation
