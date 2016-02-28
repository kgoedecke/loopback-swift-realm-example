//
//  WidgetViewController.swift
//  loopback-swift-realm-example
//
//  Created by Kevin Goedecke on 2/26/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

import UIKit
import RealmSwift

class WidgetViewController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    
    var selectedWidget: Widget!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedWidget = selectedWidget {
            self.nameTextField.text = selectedWidget.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if validateFields() {
            if let _ = selectedWidget {
                updateWidget()
            }
            else {
                addNewWidget()
            }
            return true
        }
        else {
            return false
        }
        
    }
    
    func addNewWidget() {
        
        let widgetRemote = AppDelegate.widgetRepository.modelWithDictionary(nil) as! WidgetRemote
        widgetRemote.name = self.nameTextField.text!
        widgetRemote.updated = NSDate()
        widgetRemote.saveWithSuccess({ () -> Void in
            // Add Local Object with remote_id
            let realm = try! Realm()
            try! realm.write    {
                let newWidget = Widget(remoteWidget: widgetRemote)
                realm.add(newWidget)
                self.selectedWidget = newWidget
            }
            }, failure: { (error: NSError!) -> Void in
                NSLog(error.description)
                // Save with no remote_id
                let realm = try! Realm()
                try! realm.write    {
                    let newWidget = Widget()
                    newWidget.name = self.nameTextField.text!
                    realm.add(newWidget)
                    self.selectedWidget = newWidget
                }
        })

    }
    
    func updateWidget() {
        let realm = try! Realm()
        try! realm.write {
            self.selectedWidget.name = self.nameTextField.text!
            self.selectedWidget.updated = NSDate()
            self.selectedWidget.syncWithRemote()
        }
    }
    
    func validateFields() -> Bool {
        if(nameTextField.text == "")    {
            let alertController = UIAlertController(title: "Error", message: "Please enter a name", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) { alert in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(alertAction)
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func unwindFromWidgets(segue: UIStoryboardSegue) {
        if segue.identifier == "ShowDetail" {
            let widgetsController = segue.sourceViewController as! WidgetTableViewController
            selectedWidget = widgetsController.selectedWidget
            nameTextField.text = selectedWidget.name
        }
    }
    

}
