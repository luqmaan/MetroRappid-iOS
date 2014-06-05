//
//  CAPRouteMapViewController.swift
//  MetroRappid
//
//  Created by Luq on 6/3/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class CAPRouteMapViewController: UIViewController, MKMapViewDelegate {
    
    var route: CAPRoute!
    var trip0: CAPTrip
    var trip1: CAPTrip
    
    @IBOutlet var mapView : MKMapView
    @IBOutlet var tripControl : UISegmentedControl
    
    init(coder aDecoder: NSCoder!)
    {
        trip0 = CAPTrip()
        trip1 = CAPTrip()
        super.init(coder: aDecoder)
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        trip0 = CAPTrip()
        trip1 = CAPTrip()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        mapView.delegate = self
        
        println("did load \(self)")
        
        var tripsData: Array = GTFSDB.tripsForRoute(self.route.routeId)
        
        trip0.updateWithGTFS(tripsData[0] as NSMutableDictionary)
        trip1.updateWithGTFS(tripsData[1] as NSMutableDictionary)
        
        tripControl.removeAllSegments()
        tripControl.insertSegmentWithTitle(trip0.tripHeadsign, atIndex: 0, animated: false)
        tripControl.insertSegmentWithTitle(trip1.tripHeadsign, atIndex: 1, animated: false)
        tripControl.selectedSegmentIndex = 0
    }
    
    
    
}