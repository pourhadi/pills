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
    
    
    @State var pills: [Pill] = []
    
    var loaded: Bool {
        return pills.count > 0
    }
    
    var body: some View {
        VStack {
            if loaded && pills.count > 0 {
                Text(pills.first!.takenAt.toString(.time(.short))).font(.largeTitle)
//                Text(cloudDb.all.first!.takenAt.toString(.relative(style: RelativeFormatter.timeStyle())))

            }
            Button(action: {
                self.pills.append(CloudDb.instance.pillTaken())
            }) {
                Text("Take Pill")
            }
        }
        .onReceive(CloudDb.instance.getAll().replaceError(with: []).receive(on: DispatchQueue.main), perform: { all in
            self.pills = all
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
