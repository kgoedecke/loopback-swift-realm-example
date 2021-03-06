//
//  WidgetTableViewController.swift
//  
//
//  Created by Kevin Goedecke on 2/26/16.
//
//

import UIKit
import RealmSwift
import LoopBack

class WidgetTableViewController: UITableViewController {

    let realm = try! Realm()
    lazy var widgets: Results<Widget> = { self.realm.objects(Widget) }()
    var selectedWidget: Widget!
    
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load Dummy Widgets
        populateDummyWidgets()
        
        // Set realm notification block to refresh table
        notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
            self.tableView.reloadData()
        }
        
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

    }
    
    func refresh(sender:AnyObject)
    {
        Widget.syncAllWithRemote()
        self.refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return widgets.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("widgetCell", forIndexPath: indexPath) as! WidgetTableViewCell

        let widget = widgets[indexPath.row]
        cell.nameLabel.text = widget.name
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath {
        selectedWidget = widgets[indexPath.row]
        return indexPath
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            selectedWidget = widgets[indexPath.row]
            if (selectedWidget.remoteId.value != nil) {
                AppDelegate.widgetRepository.findById(widgets[indexPath.row].remoteId.value, success: { (model: LBPersistedModel!) -> Void in
                    model.destroyWithSuccess({ () -> Void in
                        try! self.realm.write {
                            self.realm.delete(self.widgets[indexPath.row])
                        }
                        }, failure: { (err: NSError!) -> Void in
                            
                    })
                    }, failure: { (err: NSError!) -> Void in
                        if (err.code == NSURLErrorCannotConnectToHost) {
                            NSLog("Can not connect to Host")
                            let alertController = UIAlertController(title: "Error", message: "Delete is not supported while you're offline", preferredStyle: .Alert)
                            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) { alert in
                                alertController.dismissViewControllerAnimated(true, completion: nil)
                            }
                            alertController.addAction(alertAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                })
            }
            else {
                NSLog("Attempt to delete local widget that has never been synced")
                let alertController = UIAlertController(title: "Error", message: "An Error occured please refresh and try again", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) { alert in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // MARK: - Edit and Add Widget Segue operations
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let widgetDetailViewController = segue.destinationViewController as! WidgetViewController
            if let selectedWidgetCell = sender as? WidgetTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedWidgetCell)!
                let selectedWidget = widgets[indexPath.row]
                widgetDetailViewController.selectedWidget = selectedWidget
            }
        }
        else if segue.identifier == "AddWidget" {
            NSLog("Adding new widget")
        }
        
    }
    
    @IBAction func unwindToWidgetList(sender: UIStoryboardSegue) {
        // Reload is triggered by Realm Notification
    }
    
    func populateDummyWidgets() {
        if widgets.count == 0   {
            try! realm.write() {
                let defaultWidgets = ["Foo", "Bar"]
                for widget in defaultWidgets    {
                    let newWidget = Widget()
                    newWidget.name = widget
                    self.realm.add(newWidget)
                }
            }
            widgets = realm.objects(Widget)
        }
    }

}
