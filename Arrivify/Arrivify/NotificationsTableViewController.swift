//
//  NotificationsTableViewController.swift
//  Arrivify
//
//  Created by Spencer Whyte on 2016-01-01.
//  Copyright © 2016 Spencer Whyte. All rights reserved.
//

import UIKit
import CoreData

class NotificationsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView?
    
    public var context: NSManagedObjectContext!

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let notificationsFetchRequest = NSFetchRequest(entityName: "Notification")
        let primarySortDescriptor = NSSortDescriptor(key: "radius", ascending: true)
        notificationsFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: notificationsFetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.context=appDelegate.managedObjectContext
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let sections = fetchedResultsController.sections {
            print("Sections: \(sections.count)")
            return sections.count
        }
        
        return 0
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rowCount = 0

        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            rowCount = currentSection.numberOfObjects
        }
    
        if rowCount == 0{
            self.tableView?.hidden = true
        }else{
            self.tableView?.hidden = false
        }
        
        return rowCount
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Notification")
        let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
        //cell!.textLabel?.text = notification.locationName
        
        
        
        let label = cell!.viewWithTag(2) as! UILabel
        label.text = notification.locationName
  
        
        let imageView = cell!.viewWithTag(1) as! UIImageView
        let imageData = notification.image
        if  imageData != nil {
            let image = UIImage(data: imageData!)
            imageView.image = image
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
            for recipient in notification.recipients!{
                self.context.deleteObject(recipient as! NSManagedObject)
            }
            
            
            self.context.deleteObject(notification)
            
            
            
            do {
                try self.context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    @IBAction func unwindToMainView(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindWithNewNotification(segue:UIStoryboardSegue){
        if let addNotificationTableViewController = segue.sourceViewController as? AddNotificationTableViewController{
            
            let recipients = NSMutableSet()
            
            let names = addNotificationTableViewController.names
            let phoneNumbers = addNotificationTableViewController.phoneNumbers
            for(var i = 0 ; i < names.count; i++){
                let currentName = names[i]
                let currentPhoneNumber = phoneNumbers[i]
                let recipient = NSEntityDescription.insertNewObjectForEntityForName("Recipient", inManagedObjectContext: self.context) as! Recipient
                recipient.name = currentName
                recipient.phone = currentPhoneNumber
                recipients.addObject(recipient)
            }

            let notification = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: self.context) as! Notification
            notification.locationName = addNotificationTableViewController.locationName
            notification.latitude = addNotificationTableViewController.latitude!
            notification.longitude = addNotificationTableViewController.longitude!
            notification.message = addNotificationTableViewController.message
            notification.geofenceType = addNotificationTableViewController.geofenceType // Arrival, Departure, Both
            notification.radius = Int32(addNotificationTableViewController.radius) // In meters
            notification.image = UIImagePNGRepresentation(addNotificationTableViewController.locationImage!)
            notification.recipients = recipients
            
            do {
                try self.context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            self.tableView?.reloadData()
            
            print("Reloaded the table view")
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        
        print("Actually got the callback")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // TODO: Open the editor
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
/*
    optional public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    

    optional public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    

    optional public func controllerWillChangeContent(controller: NSFetchedResultsController)

    
    optional public func controllerDidChangeContent(controller: NSFetchedResultsController)

    optional public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
    */
}
