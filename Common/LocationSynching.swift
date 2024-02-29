//
//  LocationSynching.swift
//
//
//  Created by  on 2/11/16.
//  Copyright © 2016 . All rights reserved.
//

/*
 How to use the LocationSynching reusable control

 Step 1: Configure info.plist
 * NSLocationWhenInUseUsageDescription
 * NSLocationAlwaysUsageDescription
 * privacy - location usage description

 *****Set above string to plist*******

 - open info.plist

 - add in plist- NSLocationWhenInUseUsageDescription of type String
 - add in plist- NSLocationAlwaysUsageDescription of type String
 - add in plist- privacy - location usage description of type String

 The descriptions are added to the plist are blank. You can enter the text with the dedined description in plist. This text will display in Alert display to authenticate use location service with in application.

 ********************************************************************************************

 *  requestWhenInUseAuthorization(NSLocationWhenInUseUsageDescription)
 "When-in-use" authorization does NOT enable monitoring API on regions,
 *      significant location changes, or visits, and -startUpdatingLocation will
 *      not succeed if invoked from the background.

 *********************************************************************************************

 *********************************************************************************************

 *  requestAlwaysAuthorization(NSLocationAlwaysUsageDescription)
 "Always" authorization presents a significant risk to user privacy, and
 *      as such requesting it is discouraged unless background launch behavior
 *      is genuinely required.  Do not call +requestAlwaysAuthorization unless
 *      you think users will thank you for doing so.

 *********************************************************************************************

 Step 2: Open Project Targets-->open tab capabilities--> Open Background Modes-->select "Location Updates"

 Step 3: Call Location Synching class with object Parameters are Required as
 *CLLocationAccuracy(Required to 10-100 to update the location )Specifies the minimum update distance in meters.
 *CLLocationDistance

 //Protocol
 protocol UpdateLocationProtocol{
 func updateLocation(latitude:Double,logitude:Double)
 }

 * latitude - Latitude return from CLLocationManager class
 * logitude - Logitude return from CLLocationManager class

 -----------------------------------------------------------------------------
 How to Call the Location Synching class as:
 -----------------------------------------------------------------------------
 Add ContactSynchingProtocol method in AppDelegate Class
 class AppDelegate: UIResponder, UIApplicationDelegate,UpdateLocationProtocol{

 }

 //Location Synching Delegate Method
 func updateLocation(latitude: Double, logitude: Double) {

 ////Here is your Code to Synch Contacts to the server////

 }

 var locationSynching =  LocationSynching()
 locationSynching.delegate = self
 locationSynching.startUpdatingUserLocation(kCLLocationAccuracyHundredMeters , distance: 20)

 */

import Foundation
import CoreLocation
import UIKit


typealias CompletionHandlerForLocation = (_ latitude: Double, _ logitude: Double) -> Void

class LocationSynching: NSObject, CLLocationManagerDelegate {

	// Class Variables
	var latitude: Double?
	var longitude: Double?

	let locManager = CLLocationManager()
	var completionHandlerForLocation: CompletionHandlerForLocation?

	var didUpdateLocation: ((_ location: CLLocationCoordinate2D) -> ())!

	override init() {
		super.init()
        locManager.requestWhenInUseAuthorization()
	}

	// MARK:- Method to Start Location Update
	/*
	 * Params:accuracy
	 * Params:distance
	 * Params:URL
	 * Params:token
	 */
	func startUpdatingUserLocation(distance: CLLocationDistance, handler: @escaping CompletionHandlerForLocation) {

		locManager.desiredAccuracy = kCLLocationAccuracyBest
		locManager.distanceFilter = distance
		locManager.delegate = self
		locManager.startUpdatingLocation()
		completionHandlerForLocation = handler
	}

	// MARK:- Method to Stop Location Update
	func stopUpdatingUserLocation() {
		locManager.pausesLocationUpdatesAutomatically = true
		locManager.stopMonitoringSignificantLocationChanges()
		locManager.stopUpdatingLocation()
	}

//    //MARK:- CLLocationManager Delegate Methods

	/*
	 *  locationManager:didUpdateLocations:
	 *
	 *  Discussion:
	 *    Invoked when new locations are available.  Required for delivery of
	 *    deferred locations.  If implemented, updates will
	 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
	 *
	 *    locations is an array of CLLocation objects in chronological order.
	 */
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		guard let locationObj = locations.last else {
			return
		}

		let coord = locationObj.coordinate

		// Set lat/long
		self.latitude = coord.latitude
		self.longitude = coord.longitude

		if completionHandlerForLocation != nil {
			self.completionHandlerForLocation!(self.latitude!, self.longitude!)
		}


		didUpdateLocation?(coord)
	}

	/*
	 *  locationManager:didChangeAuthorizationStatus:
	 *
	 *  Discussion:
	 *    Invoked when the authorization status changes for this application.
	 */
	private func locationManager(manager: CLLocationManager,
		didChangeAuthorizationStatus status: CLAuthorizationStatus) {
			var shouldIAllow = false
			var locationStatus: NSString = "Not Started"
			switch status {
			case CLAuthorizationStatus.restricted:
				locationStatus = "Restricted Access to location"
			case CLAuthorizationStatus.denied:
				locationStatus = "User denied access to location"
			case CLAuthorizationStatus.notDetermined:
				locationStatus = "Status not determined"
			default:
				locationStatus = "Allowed to location Access"
				shouldIAllow = true
			}

			if (shouldIAllow == true) {
				print("Location to Allowed")
			} else {
				print("Denied access: \(locationStatus)")
			}
	}

	/*
	 *  locationManager:didFailWithError:
	 *
	 *  Discussion:
	 *    Invoked when an error has occurred.".
	 */
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error:\(error)")
	}

	/*
	 *  Discussion:
	 *    Invoked when location updates are automatically paused.
	 */
	func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
	}

	/*
	 *  Discussion:
	 *    Invoked when location updates are automatically resumed.
	 *
	 *    In the event that your application is terminated while suspended, you will
	 *	  not receive this notification.
	 */
	func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
	}
}
