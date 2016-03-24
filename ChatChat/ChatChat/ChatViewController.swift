/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
  
//    MARK: - Properties
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    let rootRef = Firebase(url: "https://mimichatchat.firebaseio.com")
    var messageRef: Firebase!
    var userIsTypingRef: Firebase!
    
    var userTypingQuery: FQuery!
    
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
//    MARK: - View's Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "ChatChat"
    setupBubbles()
    
    // no avatar
    collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
    collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    
    messageRef = rootRef.childByAppendingPath("messages")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    observeMessages()
    observeTyping()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
  }
   
    
//    MARK: - JSQMessages Delegate
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    
//    MARK: - Methods
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
        "text": text,
        "senderId": senderId
        ]
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    private func observeMessages() {
        let messageQuery = messageRef.queryLimitedToLast(25)
        messageQuery.observeEventType(FEventType.ChildAdded) { (snapshot: FDataSnapshot!) -> Void in
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            
            self.addMessage(id, text: text)
            self.finishReceivingMessage()
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.childByAppendingPath("typingIndicator")
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        // Initialize the query by retrieving all users who are typing
        userTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        // Observe for changes using .Value; this will give an update anytime anything changes
        userTypingQuery.observeEventType(FEventType.Value) { (data: FDataSnapshot!) -> Void in
            // You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            // Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    
    
//    MARK: - TextView Delegate
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    
    
//    The End
  
}