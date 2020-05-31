//
//  ContentView.swift
//  pills
//
//  Created by dan on 10/8/19.
//  Copyright © 2019 dan. All rights reserved.
//

import SwiftUI
import SwiftDate

struct ContentView: View {
    func update() {
    }
    
    @ObservedObject var cloudDb: DB
    
    @State private var showEdit = false
    
    @State var selection: String? = nil
    
    var pillsTakenToday: [Pill] {
        return cloudDb.all.filter { $0.takenAt.in(region: Region.local).isToday }
    }
    
    var body: some View {
        let labelText: String
        if let last = cloudDb.all.first {
            labelText = DateFormatter.localizedString(from: last.takenAt, dateStyle: .none, timeStyle: .short)
        } else {
            labelText = ""
        }
        
        return
            NavigationView {
                GeometryReader { metrics in
                    
                        VStack() {
                            Text("Last Taken:")
                                .font(.headline)
                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
                            Text(labelText)
                                .font(.largeTitle)
                            Spacer()
                            Text("Taken Today:")
                                .font(.headline)
                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
                            Text("\(self.pillsTakenToday.count)")
                                .font(.largeTitle)
                            Spacer()
                            Button(action: {
                                CloudDb.instance.pillTaken()
                                
                            }) {
                                Text("Take Pill")
                                .bold() .foregroundColor(Color(UIColor.systemBackground))
                                    .padding(.all)
                            }
                            .frame(width: 200.0)
                            .background(RoundedRectangle(cornerRadius: 8))
                            Spacer()
                        }

                        .frame(width: metrics.size.width, height: metrics.size.height * 0.5, alignment: Alignment.top)
                        ItemList(cloudDb: self.cloudDb, selection: self.$selection).frame(height: metrics.size.height * 0.5).offset(x: 0, y: metrics.size.height / 2)
                    }
                    
//                }
        }.navigationBarHidden(true)
                .accentColor(Color.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(cloudDb: DummyDb())
    }
}
