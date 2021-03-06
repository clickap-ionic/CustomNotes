//
//  NotesVC.swift
//  Notes
//
//  Created by Alessandro Musto on 3/1/17.
//  Copyright © 2017 Lmusto. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices



class NotesVC: UIViewController, UITextViewDelegate {

    var textView: ClickableTextView!
    var text: String!

    var note: Note?
    let coreStack = CoreDataStack.store

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(onBack(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onShare(_:)))


        textView = ClickableTextView(frame: CGRect.zero, textContainer: nil)
        textView.delegate = self
        textView.frame = view.frame

        setInitialText()

        view.addSubview(textView)


    }


    func onBack(_ backButton: UIBarButtonItem) {
        if let text = textView.text {
            if note == nil {
                let date = NSDate()
                coreStack.storeNote(withTitle: text, onDate: date)
            } else {
                note!.title = text
                coreStack.saveContext()
            }
        }
        navigationController!.popViewController(animated: true)

    }

    func setInitialText() {
        if let note = note {
            textView.text = note.title
        } else {
            textView.text = nil
        }
    }

    func onShare(_ button:UIBarButtonItem) {
        var objectsToShare = [String]()

        if let text = textView.text {
            objectsToShare.append(text)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)

        activityVC.completionWithItemsHandler =
            { (activityType, completed, returnedItems, error) in

                guard let returnedItems = returnedItems else {return}
                if returnedItems.count > 0 {

                    let textItem: NSExtensionItem =
                        returnedItems[0] as! NSExtensionItem

                    let textItemProvider =
                        textItem.attachments![0] as! NSItemProvider

                    if textItemProvider.hasItemConformingToTypeIdentifier(
                        kUTTypeText as String) {
                        
                        textItemProvider.loadItem(
                            forTypeIdentifier: kUTTypeText as String,
                            options: nil,
                            completionHandler: {(string, error) -> Void in
                                let newtext = string as! String
                                self.textView.text = newtext
                        })
                    }
                }
        }
    }
}


