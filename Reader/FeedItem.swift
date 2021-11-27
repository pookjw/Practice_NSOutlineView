//
//  FeedItem.swift
//  Reader
//
//  Created by Jinwoo Kim on 11/28/21.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import Cocoa

class FeedItem: NSObject {
  let url: String
  let title: String
  let publishingDate: Date
  
  init(dictionary: NSDictionary) {
    self.url = dictionary.object(forKey: "url") as! String
    self.title = dictionary.object(forKey: "title") as! String
    self.publishingDate = dictionary.object(forKey: "date") as! Date
  }
}
