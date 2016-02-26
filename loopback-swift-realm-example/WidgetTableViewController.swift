//
//  WidgetTableViewController.swift
//  
//
//  Created by Kevin Goedecke on 2/26/16.
//
//

import UIKit
import RealmSwift

class WidgetTableViewController: UITableViewController {

    let realm = try! Realm()
    lazy var widgets: Results<Widget> = { self.realm.objects(Widget) }()
    var selectedWidget: Widget!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load Dummy Widgets
        populateDummyWidgets()

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
            // Delete is currently not supported in offline mode
            //let selectedWidget = widgets[indexPath.row]
            //try! realm.write {
            //    realm.delete(selectedWidget)
            //}
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let alertController = UIAlertController(title: "Error", message: "Delete is not supported while you're offline", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) { alert in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(alertAction)
            presentViewController(alertController, animated: true, completion: nil)
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
        self.tableView.reloadData()
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
