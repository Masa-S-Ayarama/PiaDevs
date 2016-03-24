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


class LoginViewController: UIViewController {
  
//    MARK: - Properties
    var rootRef : Firebase!
    
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    rootRef = Firebase(url: "https://mimichatchat.firebaseio.com")
  }

  @IBAction func loginDidTouch(sender: AnyObject) {
    rootRef.authAnonymouslyWithCompletionBlock { (error, authData) in // 1
        if error != nil { print(error.description); return } // 2
        self.performSegueWithIdentifier("LoginToChat", sender: nil) // 3
    }
  }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVC = segue.destinationViewController as! UINavigationController
        let chatVC = navVC.viewControllers.first as! ChatViewController
        chatVC.senderId = rootRef.authData.uid
        chatVC.senderDisplayName = ""
    }
 
    
    
// The End
}

