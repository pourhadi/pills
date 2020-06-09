//
//  TodayViewController.swift
//  widget
//
//  Created by dan on 10/8/19.
//  Copyright © 2019 dan. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftDate
import Combine

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var takePillButton: UIButton!
    @IBOutlet weak var relativeLabel: UILabel!
    
    private var cloudDb = CloudDb.instance
    
    private var all = [Pill]()
    
    private var cancellable: AnyCancellable?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.preferredContentSize = CGSize(width: UIView.noIntrinsicMetric, height: 80.0)
        
        takePillButton.layer.cornerRadius = 6
        update()
        
        cancellable = cloudDb.objectWillChange.receive(on: DispatchQueue.main).sink { () in
            self.update()
        }
        
        self.takePillButton.isEnabled = false
    }
    var updated = false
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        cloudDb.refresh()
        
        update()
        completionHandler(NCUpdateResult.newData)
        
        self.takePillButton.isEnabled = true
        self.updated = true
    }
    
    func update() {
        if let last = cloudDb.all.first {
            lastTakenLabel.text = DateFormatter.localizedString(from: last.takenAt, dateStyle: .none, timeStyle: .short)
//            let style = RelativeFormatter.Style(
            relativeLabel.text = last.takenAt.toString(.relative(style: RelativeFormatter.twitterStyle()))
        } else {
            lastTakenLabel.text = ""
        }
    }
    
    @IBAction func takePill() {
        
        if !self.updated {
            return
        }
        cloudDb.pillTaken()
//        update()
    }

}
