//
//  ComplicationController.swift
//  pillsForWatch Extension
//
//  Created by Daniel Pourhadi on 5/30/20.
//  Copyright © 2020 dan. All rights reserved.
//

import ClockKit
import Combine
import SwiftDate

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    var c: AnyCancellable?
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        c?.cancel()
        
        c = CloudDb.instance
            .getAll()
        .replaceError(with: [])
            .receive(on: DispatchQueue.main).sink { val in
                guard val.count > 0 else { return }
                
                let pill = val.first!
                let complication = CLKComplicationTemplateGraphicCornerGaugeText()

                let threehours = pill.takenAt.addingTimeInterval(60 * 60 * 3)
                
                let fraction = pill.takenAt.timeIntervalSinceNow / (60 * 60 * 3)
                
//                let timelineProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [UIColor.green, UIColor.yellow, UIColor.red], gaugeColorLocations:nil, start: pill.takenAt, end: pill.takenAt.addingTimeInterval(60 * 60 * 3))
               
                let color = fraction < 0.3 ? UIColor.green : fraction < 0.6 ? UIColor.orange : UIColor.red
                
                let timelineProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: color, fillFraction: Float(fraction))
//                let outerText = CLKSimpleTextProvider(text: pill.takenAt.addingTimeInterval(60 * 60 * 3).toString(.time(.short)))

                let outerText = CLKSimpleTextProvider(text: pill.takenAt.toString(.time(.short)))

                complication.gaugeProvider = timelineProvider
                complication.outerTextProvider = outerText
                
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate:complication)
                
                handler(entry)
        }

    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
