//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore() // our Cloud FireStore data bsae
    
    var messages: [Message] = [
        Message(sender: "Hami", body: "HI"),
        Message(sender: "Tania", body: "get back home you idiot youa are xomning back home right nowwwwwwwwwww!!!!!!!!!!!!1"),
        Message(sender: "Alex", body: "see you there")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        let titel = K.appName
        navigationItem.title = titel

        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages() // Reading our messages from data base
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        // 1. if textfield is not empty
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            // 2. send the message to data base
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
        }
    }
    
    @IBAction func LogoutButton(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
}

//MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        return cell
    }
}

//MARK: - loadMessages

extension ChatViewController {
    func loadMessages() {
        // 1. reach our collection with getDocuments method, recieve data (querySnapshot)
        db.collection(K.FStore.collectionName).getDocuments { querySnapshot, err in
            if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // 2. store documents in (snapshotDocuments) if they exist
                    if let snapshotDocuments = querySnapshot?.documents {
                        // 3. loop through documents "messages"
                        for doc in snapshotDocuments {
                            // 4. get the data "sender and body", with .data() method
                            let data = doc.data()
                            // 5. firebase documents can include any data type, so we have to downcast the sender and body to a string, in order to use them in Message() model
                            if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                                let newMessage = Message(sender: messageSender, body: messageBody)
                                self.messages.append(newMessage)
                                
                                // 6. reload the table view
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
        }
    }
}
