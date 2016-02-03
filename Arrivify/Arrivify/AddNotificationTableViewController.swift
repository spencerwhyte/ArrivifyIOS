//
//  AddNotificationTableViewController.swift
//  Arrivify
//
//  Created by Spencer Whyte on 2016-01-01.
//  Copyright © 2016 Spencer Whyte. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Contacts


class AddNotificationTableViewController: UITableViewController, THContactPickerViewControllerDelegate {
    
    @IBOutlet var doneButton:UIBarButtonItem?
    
    var geofenceType:String="Arrival"
    
    var placePicker:GMSPlacePicker?
    var contactPicker:UIViewController?
    
    var mapCell:UITableViewCell?
    var radiusCell:UITableViewCell?
    var arrivalDepartureBothCell:UITableViewCell?
    var messageCell:UITableViewCell?
    
    var names:Array<String> = []
    var phoneNumbers:Array<String> = []
    
    var locationName:String?
    
    var locationImage:UIImage?
    
    var latitude:Double?
    var longitude:Double?
    
    var previousNotification:Notification?
    
    
    var radius:Int32=500
    
    var message:String {
        get {
            let deviceName = UIDevice().name
            let userName = self.nameFromDeviceName(deviceName).joinWithSeparator(" ")
            let segmentControl = self.arrivalDepartureBothCell?.viewWithTag(1) as! UISegmentedControl
            var modifier = ""
            if(segmentControl.selectedSegmentIndex == 0){ // Arrival
                modifier = "arrived at"
            }else if(segmentControl.selectedSegmentIndex == 1){ // Departure
                modifier = "departed from"
            }else{ // Both
                modifier = "{departed from,arrived at}"
            }
            if(self.locationName == nil){
                return "\(userName) has just \(modifier) some location"
            }else{
                return "\(userName) has just \(modifier) \(self.locationName!)"
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.tableView.backgroundView = blurEffectView
        
        self.tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        
        //self.tableView.backgroundView = blurEffectView
        
        if(self.previousNotification != nil){
            self.navigationItem.title = "Edit Notification"
        }
        
        self.updateDoneButtonState()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){ // Map
            return 1
        }else if(section == 1){ // Radius
            return 1
        }else if(section == 2){ // Trigger
            return 1
        }else if(section == 3){ // Message
            return 1
        }else if(section == 4){ // recipients
            return 1 + self.names.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("Map")
            self.mapCell = cell
            if(self.locationImage != nil){
                let mapImageView = self.mapCell?.viewWithTag(1) as! UIImageView
                mapImageView.image = self.locationImage
            }
            cell?.backgroundColor = UIColor.clearColor()
            return cell!
        }else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("Radius")
            self.radiusCell = cell
            
            let segmentControl = self.radiusCell?.viewWithTag(1) as! UISegmentedControl
            if(self.radius == 250){
                segmentControl.selectedSegmentIndex = 0
            }else if(self.radius == 500){
                segmentControl.selectedSegmentIndex = 1
            }else if(self.radius == 1000){
                segmentControl.selectedSegmentIndex = 2
            }
            segmentControl.addTarget(self, action: "radiusDidChange:", forControlEvents: UIControlEvents.ValueChanged)
            
            cell?.backgroundColor = UIColor.clearColor()
            return cell!
        }else if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCellWithIdentifier("ArrivalDepartureBoth")
            self.arrivalDepartureBothCell = cell
            
            let segmentControl = self.arrivalDepartureBothCell?.viewWithTag(1) as! UISegmentedControl
            if(self.geofenceType == "Arrival"){
                segmentControl.selectedSegmentIndex = 0
            }else if(self.geofenceType == "Departure"){
                segmentControl.selectedSegmentIndex = 1
            }else if(self.geofenceType == "Both"){
                segmentControl.selectedSegmentIndex = 2
            }
            
            segmentControl.addTarget(self, action: "arrivalDepartureBothChange:", forControlEvents: UIControlEvents.ValueChanged)
            
            cell?.backgroundColor = UIColor.clearColor()
            return cell!
        }else if(indexPath.section == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("Message")
            cell?.backgroundColor = UIColor.clearColor()
            ///cell?.textLabel.lineBreakMode = ;
            cell?.textLabel!.numberOfLines = 2;
            cell?.textLabel?.textColor = UIColor(red: 0, green: 111.0/255.0, blue: 220.0/225.0, alpha: 1.0)
            self.messageCell = cell
            self.updateMessage()
            return cell!
        }else if(indexPath.section == 4){
            let cell = tableView.dequeueReusableCellWithIdentifier("Person")
            cell?.textLabel?.textColor = UIColor(red: 0, green: 111.0/255.0, blue: 220.0/225.0, alpha: 1.0)
            if(indexPath.row == 0){
                if(self.names.isEmpty){
                    cell?.textLabel?.text = "Tap to select recipients"
                }else{
                    cell?.textLabel?.text = "Tap to edit recipients"
                }
                cell?.detailTextLabel?.text = ""
                cell?.backgroundColor = UIColor.clearColor()
                return cell!
            }else{
                let index = indexPath.row - 1
                cell?.textLabel!.text = self.names[index]
                cell?.detailTextLabel!.text = self.phoneNumbers[index]
                cell?.backgroundColor = UIColor.clearColor()
                return cell!
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return 200
        }else if(indexPath.section == 3){
            return 88
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Location"
        }else if(section == 1){
            return "Radius"
        }else if(section == 2){
            return "Trigger"
        }else if(section == 3){
            return "Message"
        }else if(section == 4){
            return "Recipients"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section == 0){
            self.displayPlacePicker()
        }else if(indexPath.section == 4){
            self.displayPeoplePicker()
        }
    }
    
    func radiusDidChange(sender:AnyObject){
        let segmentControl = self.radiusCell?.viewWithTag(1) as! UISegmentedControl
        let segmentIndex = segmentControl.selectedSegmentIndex
        if(segmentIndex == 0){
            self.radius = 250
        }else if(segmentIndex == 1){
            self.radius = 500
        }else if(segmentIndex == 2){
            self.radius = 1000
        }
        print("Radius Did Change")
    }
    
    func arrivalDepartureBothChange(sender:AnyObject){
        let segmentControl = self.arrivalDepartureBothCell?.viewWithTag(1) as! UISegmentedControl
        let segmentIndex = segmentControl.selectedSegmentIndex
        if(segmentIndex == 0){
            self.geofenceType = "Arrival"
        }else if(segmentIndex == 1){
           self.geofenceType = "Departure"
        }else if(segmentIndex == 2){
            self.geofenceType = "Both"
        }
        self.updateMessage()
    }
    
    func updateDoneButtonState(){
        if(!self.names.isEmpty && !self.phoneNumbers.isEmpty && self.locationName != "location" && self.latitude != nil && self.longitude != nil && self.locationImage != nil){ // Make sure that they have selected a contact and a location
            self.doneButton?.enabled = true
        }else{
            self.doneButton?.enabled = false
        }
    }
    
    
    func displayPeoplePicker(){
        CNContactStore().requestAccessForEntityType(CNEntityType.Contacts) { (success:Bool, error:NSError?) -> Void in }
        let contactPickerViewController = THContactPickerViewController(nibName: "THContactPickerViewController", bundle: nil, initiallySelectedPhoneNumbers:self.phoneNumbers)
        contactPickerViewController.delegate = self
        let navController = UINavigationController(rootViewController: contactPickerViewController)
        self.navigationController?.presentViewController(navController, animated: true, completion: { () -> Void in
            print("Did finish presenting contact picker")
        })
    }
    
    func displayPlacePicker(){
        if(self.placePicker == nil){
            if(self.locationName != nil){ // If we already have a location
                let center = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
                let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
                let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                let config = GMSPlacePickerConfig(viewport: viewport)
                self.placePicker = GMSPlacePicker(config: config)
            }else{
                let center = CLLocationManager().location?.coordinate
                if(center != nil){
                    let northEast = CLLocationCoordinate2DMake(center!.latitude + 0.001, center!.longitude + 0.001)
                    let southWest = CLLocationCoordinate2DMake(center!.latitude - 0.001, center!.longitude - 0.001)
                    let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                    let config = GMSPlacePickerConfig(viewport: viewport)
                    self.placePicker = GMSPlacePicker(config: config)
                }else{
                    let northEast = CLLocationCoordinate2DMake(37.7833 + 0.001, -122.4167 + 0.001)
                    let southWest = CLLocationCoordinate2DMake(37.7833 - 0.001, -122.4167 - 0.001)
                    let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                    let config = GMSPlacePickerConfig(viewport: viewport)
                    self.placePicker = GMSPlacePicker(config: config)
                }
            }
            
        }
        self.placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let place = place{
                let mapImageView = self.mapCell?.viewWithTag(1) as! UIImageView
                let width = Int(mapImageView.frame.width) * 2
                let height = Int(mapImageView.frame.height) * 2
                //maptype=satellite
                let queryString = "https://maps.google.com/maps/api/staticmap?markers=color:red|\(place.coordinate.latitude),\(place.coordinate.longitude)&zoom=19&size=\(width)x\(height)&sensor=true&maptype=satellite"
                
                let percentEscapedQueryString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                let mapURL = NSURL(string: percentEscapedQueryString!)
                
                
                
                let data = NSData(contentsOfURL: mapURL!);
                if(data != nil){
                    let image = UIImage(data: data!);
                    mapImageView.image = image
                    self.locationImage = image
                    
                    if let placeName = place.name{
                        self.locationName = placeName
                    }else if let placeAddress = place.formattedAddress{
                        self.locationName = placeAddress
                    }else{
                        self.locationName = "location"
                    }

                    self.latitude = place.coordinate.latitude
                    self.longitude = place.coordinate.longitude
                    
                    self.updateMessage()
                    self.updateDoneButtonState()
                    
                    
                }else{
                    let alert:UIAlertView = UIAlertView(title: "No Internet Connection", message: "Please try again when you have an internet connection", delegate: nil, cancelButtonTitle: "OK")
                    alert.show();
                }
                
                
                
            
            }
        })
    }
    
    func updateMessage(){
        if(self.messageCell != nil){
            self.messageCell?.textLabel!.text = self.message
        }
    }
    
    // Array of THContacts
    func didFinishSelectingContacts(contactPhoneNumbers: [AnyObject]!) {
        self.names = []
        self.phoneNumbers = []
        for contact in contactPhoneNumbers{

            let actualContact = contact as! THContact
            print(actualContact)
            print("\(actualContact.phone)")
            if let lastName = actualContact.lastName {
                if(lastName != "nil"){
                    self.names.append("\(actualContact.firstName) \(actualContact.lastName)")
                }else{
                    self.names.append("\(actualContact.firstName)")
                }
            }else{
                self.names.append("\(actualContact.firstName)")
            }
            self.phoneNumbers.append("\(actualContact.phone)")
            
            
        }
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true) { () -> Void in
            print("Done dismiss view controller")
        }
        self.updateDoneButtonState()
    }
    
    
    // TODO: Move this into it's own utility class
    func nameFromDeviceName(deviceName:String) -> [String]
    {
        let oldDeviceName = deviceName as NSString
        
        let expression:String = "^(?:iPhone|phone|iPad|iPod)\\s+(?:de\\s+)?|(\\S+?)(?:['’]?s)?(?:\\s+(?:iPhone|phone|iPad|iPod))?$|(\\S+?)(?:['’]?的)?(?:\\s*(?:iPhone|phone|iPad|iPod))?$|(\\S+)\\s+"
        
        
        do {
            let regex = try NSRegularExpression(pattern: expression, options: NSRegularExpressionOptions.CaseInsensitive)
            var name:[String] = []
            let results = regex.matchesInString(deviceName, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, deviceName.characters.count))
            
            for result in results {
                for (var i = 1; i < result.numberOfRanges; i++) {
                    if (result.rangeAtIndex(i).location != NSNotFound) {
                        let piece = oldDeviceName.substringWithRange(result.rangeAtIndex(i)).capitalizedString
                        name.append(piece)
                    }
                }
            }
            return name;
        } catch  {
            return ["Someone"]
        }
        
    }

    
    
}
