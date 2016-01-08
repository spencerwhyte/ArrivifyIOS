//: Playground - noun: a place where people can play

import UIKit




func nameFromDeviceName(deviceName:String) -> [String]
{
    let oldDeviceName = deviceName as NSString
    
    let expression:String = "^(?:iPhone|phone|iPad|iPod)\\s+(?:de\\s+)?|(\\S+?)(?:['’]?s)?(?:\\s+(?:iPhone|phone|iPad|iPod))?$|(\\S+?)(?:['’]?的)?(?:\\s*(?:iPhone|phone|iPad|iPod))?$|(\\S+)\\s+"
    
    
    do {
        let regex = try NSRegularExpression(pattern: expression, options: NSRegularExpressionOptions.CaseInsensitive)
        var name:[String] = []
        let results = regex.matchesInString(deviceName, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, deviceName.characters.count))
        
        for result in results {
            print("Hel")
            for (var i = 1; i < result.numberOfRanges; i++) {
                print("Stop2")
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

var deviceName = "Keleisha's iPhone"

let userName = 

