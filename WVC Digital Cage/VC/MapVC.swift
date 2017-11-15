//
//  MapVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/15/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class MapVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let Slayer = CAShapeLayer()
        //Slayer.opacity = 0.5
       // Slayer.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 64, width: 100, height: 70), cornerRadius: 5).cgPath
        //Slayer.fillColor = UIColor.polar().cgColor
        //Slayer.lineWidth = 2
        //Slayer.strokeColor = UIColor.backButtonBlue().cgColor
        
        //let label = UILabel()
        //label.font = UIFont(name: "Helvetica-Bold", size: 12)
        //let center : CGPoint = CGPoint(x: CGRect.midX(Slayer.bounds), y: CGRectGetMidX(Slayer.bounds))
        //label.text = "Hello"
        //label.textColor = UIColor.red
        //label.isHidden = false
        
        //mapView.layer.addSublayer(Slayer)
        
        //drawRow(startX:200,startY:64, cells:7, cellHeight: 70, cellwidth: 100)
        //drawRow(startX:200+100+5,startY:64, cells:7, cellHeight: 70, cellwidth: 100)
        
        //scrollView.delegate = self
        //scrollView.minimumZoomScale = 1.0
        //scrollView.maximumZoomScale = 3.0
        //scrollView.zoomScale = 1.0
    }

//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return mapView
//    }
//    func drawRow(startX:Int,startY:Int, cells:Int, cellHeight:Int, cellwidth:Int)
//    {
//        var newStartY = startY-cellHeight
//        cells.times {
//            newStartY += cellHeight
//            let layer = CAShapeLayer()
//            layer.path = UIBezierPath(roundedRect: CGRect(x: startX, y: newStartY, width: cellwidth, height: cellHeight), cornerRadius: 5).cgPath
//            layer.fillColor = UIColor.polar().cgColor
//            layer.lineWidth = 2
//            layer.strokeColor = UIColor.backButtonBlue().cgColor
//            mapView.layer.addSublayer(layer)
//        }
//    }
    
}
