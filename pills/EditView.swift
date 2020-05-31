//
//  EditView.swift
//  pills
//
//  Created by dan on 11/10/19.
//  Copyright © 2019 dan. All rights reserved.
//

import SwiftUI

struct EditView: View {
    let pill: Pill
    let cloudDb: DB
    var newDate: State<Date>
    
    init(pill: Pill, cloudDb: DB) {
        self.pill = pill
        self.cloudDb = cloudDb
        self.newDate = State(initialValue: pill.takenAt)
    }
    
    var body: some View {
        DatePicker(selection: newDate.projectedValue, label: { Text("Edit") }).labelsHidden().onDisappear {
            if self.pill.takenAt != self.newDate.wrappedValue {
                self.cloudDb.delete(pill: self.pill)
                self.cloudDb.add(date: self.newDate.wrappedValue)
            }
        }
    }
    
    
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(pill: Pill(), cloudDb: DummyDb())
    }
}
