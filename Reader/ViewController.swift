/*
* Copyright (c) 2016 Razeware LLC
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

import Cocoa
import WebKit

class ViewController: NSViewController {
  
  @IBOutlet weak var webView: WebView!
  @IBOutlet weak var outlineView: NSOutlineView!
  
  var feeds = [Feed]()
  let dateFormatter = DateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateFormatter.dateStyle = .short
    
    if let filePath = Bundle.main.path(forResource: "Feeds", ofType: "plist") {
      feeds = Feed.feedList(filePath)
    }
    
    outlineView.reloadData()
  }
  
  @IBAction func doubleClickedItem(_ sender: NSOutlineView) {
    let item = sender.item(atRow: sender.clickedRow)
    
    if item is Feed {
      if sender.isItemExpanded(item) {
        sender.collapseItem(item)
      } else {
        sender.expandItem(item)
      }
    }
  }
  
  override func keyDown(with event: NSEvent) {
    interpretKeyEvents([event])
  }
  
  override func deleteBackward(_ sender: Any?) {
    let selectedRow = outlineView.selectedRow
    if selectedRow == -1 {
      return
    }
    
    outlineView.beginUpdates()
    
    //
    
    if let item = outlineView.item(atRow: selectedRow) {
      
      if let item = item as? Feed {
        
        if let index = self.feeds.firstIndex(where: { $0.name == item.name }) {
          
          self.feeds.remove(at: index)
          
          outlineView.removeItems(at: IndexSet(integer: selectedRow), inParent: nil, withAnimation: .slideLeft)
        }
      } else if let item = item as? FeedItem {
        
        for feed in self.feeds {
          if let index = feed.children.firstIndex(where: { $0.title == item.title }) {
            feed.children.remove(at: index)
            
            outlineView.removeItems(at: IndexSet(integer: index), inParent: feed, withAnimation: .slideLeft)
          }
        }
      }
    }
    
    //
    
    outlineView.endUpdates()
  }
}

extension ViewController: NSOutlineViewDataSource {
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if let feed = item as? Feed {
      return feed.children.count
    }
    
    return feeds.count
  }
  
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let feed = item as? Feed {
      return feed.children[index]
    }
    
    return feeds[index]
  }
  
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if let feed = item as? Feed {
      return feed.children.count > 0
    }
    
    return false
  }
}

extension ViewController: NSOutlineViewDelegate {
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    var view: NSTableCellView?
    
    if let feed = item as? Feed {
      
      if tableColumn?.identifier.rawValue == "DateColumn" {
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
          textField.stringValue = ""
          textField.sizeToFit()
        }
        
      } else {
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FeedCell"), owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
          textField.stringValue = feed.name
          textField.sizeToFit()
        }
      }
      
    } else if let feedItem = item as? FeedItem {
      
      if tableColumn?.identifier.rawValue == "DateColumn" {
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
          textField.stringValue = dateFormatter.string(from: feedItem.publishingDate)
          textField.sizeToFit()
        }
        
      } else {
        
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FeedItemCell"), owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
          textField.stringValue = feedItem.title
          textField.sizeToFit()
        }
        
      }
    }
    
    return view
  }
  
  func outlineViewSelectionDidChange(_ notification: Notification) {
    
    guard let outlineView = notification.object as? NSOutlineView else {
      return
    }
    
    let selectedIndex = outlineView.selectedRow
    
    if let feedItem = outlineView.item(atRow: selectedIndex) as? FeedItem {
      let url = URL(string: feedItem.url)
      
      if let url = url {
        self.webView.mainFrame.load(URLRequest(url: url))
      }
    }
  }
}
