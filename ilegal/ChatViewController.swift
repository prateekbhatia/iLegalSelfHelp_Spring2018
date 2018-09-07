//
//  ChatViewController.swift
//  ilegal
//
//  Created by Peter Lu on 10/17/17.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var handle: AuthStateDidChangeListenerHandle?
    
    var emailString: String = ""
    
    private var chatsRefHandle: DatabaseHandle?
    private var chatsRefHandle2: DatabaseHandle?
    
    static let databaseRoot = Database.database().reference()
    static let databaseChats = databaseRoot.child("chats")
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        
        senderId = User.currentUser.firstName
        senderDisplayName = User.currentUser.firstName
        if (emailString == ""){
            emailString = User.currentUser.email
        }

        emailString = emailString.replacingOccurrences(of: ".", with: "")
        
        observeChat()
        
        self.collectionView.layoutIfNeeded()
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }, completion: nil)

 
    }
    
    private func observeChat() {
        Constants.refs.databaseChats.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(self.emailString){
                let query = Constants.refs.databaseChats.child(self.emailString).queryLimited(toLast: 10)
                
                _ = query.observe(.childAdded, with: { [weak self] snapshot in
                    
                    if  let data        = snapshot.value as? [String: String],
                        let id          = data["sender_id"],
                        let name        = data["name"],
                        let text        = data["text"],
                        !text.isEmpty
                    {
                        if let message = JSQMessage(senderId: id, displayName: name, text: text)
                        {
                            self?.messages.append(message)
                            self?.finishReceivingMessage()
                        }
                    }
                })
            }
        })
        
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderDisplayName == User.currentUser.firstName ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        
        let ref = Constants.refs.databaseChats.child(self.emailString).childByAutoId()
        
        let message = ["sender_id": senderDisplayName, "name": senderDisplayName, "text": text]
        
        ref.setValue(message)
        
        finishSendingMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


