//
//  ContentView.swift
//  pillsForWatch Extension
//
//  Created by Daniel Pourhadi on 5/30/20.
//  Copyright © 2020 dan. All rights reserved.
//

import SwiftUI
import SwiftDate

struct ContentView: View {
    
    @ObservedObject var cloudDb: CloudDb = CloudDb.instance
    
    @State var pills: [Pill] = []
    
    var loaded: Bool {
        print("\(cloudDb.all.count)")
        return cloudDb.all.count > 0
    }
    
    init() {
        self.cloudDb.refresh()
    }
    
    var body: some View {
        VStack {
            if loaded {
                Text(DateFormatter.localizedString(from: cloudDb.all.first!.takenAt, dateStyle: .none, timeStyle: .short)).font(.largeTitle)
//                Text(cloudDb.all.first!.takenAt.toString(.relative(style: RelativeFormatter.timeStyle())))

            }
            Button(action: {
                self.cloudDb.pillTaken()
            }) {
                Text("Take Pill")
            }
        }
        .onReceive(cloudDb.$all, perform: { all in
            self.pills = all
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
