//
//  NotificationsTableViewController.swift
//  Arrivify
//
//  Created by Spencer Whyte on 2016-01-01.
//  Copyright © 2016 Spencer Whyte. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation



class NotificationsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView?
    
    var context: NSManagedObjectContext!
    
    
    var locationManager:CLLocationManager{
        get{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.locationManager
        }
    }

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
        
        let tintView = cell!.viewWithTag(4)!
        tintView.hidden = notification.enabled
        
        let enabledSwitch = cell!.viewWithTag(3) as! UISwitch
        enabledSwitch.addTarget(self, action: "enabledStateDidChange:", forControlEvents: UIControlEvents.ValueChanged)
        enabledSwitch.on = notification.enabled
        

        
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
            
            self.stopMonitoringGeoNotificationWithIdentifier(notification.identifier!)
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "EditNotification"){
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let addNotificationTableViewController = navigationController.viewControllers[0] as! AddNotificationTableViewController
            
            if let selectedNotificationCell = sender as? UITableViewCell {
                let indexPath = tableView?.indexPathForCell(selectedNotificationCell)
                let notification = fetchedResultsController.objectAtIndexPath(indexPath!) as! Notification
                
                addNotificationTableViewController.previousNotification = notification
                
                var names = Array<String>()
                var phoneNumbers = Array<String>()
                
                let recipients = notification.recipients!
                for recipient in recipients{
                    names.append(recipient.name)
                    phoneNumbers.append(recipient.phone)
                }
                
                addNotificationTableViewController.names = names;
                addNotificationTableViewController.phoneNumbers = phoneNumbers;
                addNotificationTableViewController.locationName = notification.locationName!
                addNotificationTableViewController.latitude = notification.latitude
                addNotificationTableViewController.longitude = notification.longitude
                addNotificationTableViewController.geofenceType = notification.geofenceType!
                addNotificationTableViewController.radius = notification.radius // In meters
                addNotificationTableViewController.locationImage = UIImage(data: notification.image!)
                
                
            }
            
            
        }
        
    }

    
    
    @IBAction func unwindToMainView(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindWithNewNotification(segue:UIStoryboardSegue){
        if let addNotificationTableViewController = segue.sourceViewController as? AddNotificationTableViewController{
            if(addNotificationTableViewController.previousNotification == nil){
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
                notification.radius = addNotificationTableViewController.radius // In meters
                notification.image = UIImagePNGRepresentation(addNotificationTableViewController.locationImage!)
                notification.recipients = recipients
                notification.identifier = NSUUID().UUIDString
                notification.enabled = true
                self.startMonitoringGeoNotification(notification)
            }else{
                let notification = addNotificationTableViewController.previousNotification!
                
                notification.locationName = addNotificationTableViewController.locationName
                notification.latitude = addNotificationTableViewController.latitude!
                notification.longitude = addNotificationTableViewController.longitude!
                notification.message = addNotificationTableViewController.message
                notification.geofenceType = addNotificationTableViewController.geofenceType // Arrival, Departure, Both
                print("At exit \(addNotificationTableViewController.radius)")
                notification.radius = addNotificationTableViewController.radius // In meters
                notification.image = UIImagePNGRepresentation(addNotificationTableViewController.locationImage!)
                
                let previousRecipients = notification.recipients!
                for recipient in previousRecipients{
                    self.context.deleteObject(recipient as! NSManagedObject)
                }
    
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
                notification.recipients = recipients
                
                self.stopMonitoringGeoNotificationWithIdentifier(notification.identifier!)
                self.startMonitoringGeoNotification(notification)
                
            }
            
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func enabledStateDidChange(sender:AnyObject){
        let switchView = sender as! UISwitch
        let contentView = switchView.superview
        let cellView = contentView?.superview as! UITableViewCell
        let indexPath = self.tableView?.indexPathForCell(cellView)
        let notification = fetchedResultsController.objectAtIndexPath(indexPath!) as! Notification
        let tintView = cellView.viewWithTag(4)!
        notification.enabled = switchView.on
        tintView.hidden = notification.enabled
        
        if(notification.enabled){
            self.startMonitoringGeoNotification(notification)
        }else{
            self.stopMonitoringGeoNotificationWithIdentifier(notification.identifier!)
        }
        
        do {
            try self.context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        
        
    }
    
    
    func startMonitoringGeoNotification(notification:Notification){
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            //showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            // TODO: Handle this case
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            //showSimpleAlertWithTitle("Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.", viewController: self)
            
            // TODO: Handle this case
            
        }
        // 3
        let coordinate = CLLocationCoordinate2D(latitude:notification.latitude, longitude: notification.longitude)
        let region = CLCircularRegion(center: coordinate, radius: Double(notification.radius), identifier: notification.identifier!)
        // 2
        if(notification.geofenceType == "Arrival"){
            region.notifyOnEntry = true
            region.notifyOnExit = false
        }
        if(notification.geofenceType == "Departure"){
            region.notifyOnExit = true
            region.notifyOnEntry = false
        }
        if(notification.geofenceType == "Both"){
            region.notifyOnExit = true
            region.notifyOnEntry = true
        }
        
        // 4
        self.locationManager.startMonitoringForRegion(region)
    }
    
    func stopMonitoringGeoNotificationWithIdentifier(identifier:String){
        for region in self.locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == identifier {
                    self.locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }

}
