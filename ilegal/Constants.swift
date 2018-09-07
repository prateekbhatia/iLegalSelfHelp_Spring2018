//
//  Constants.swift
//  ilegal
//
//  Created by Peter Lu on 10/16/17.
//

import Foundation
import Firebase

struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}
