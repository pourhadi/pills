//
//  ItemView.swift
//  pills
//
//  Created by dan on 10/31/19.
//  Copyright © 2019 dan. All rights reserved.
//

import SwiftUI
import SwiftDate

struct ItemView: View {
    
    @Binding var selection: String?
    
    var pill: Pill
    
    var isSelected: Bool {
        return selection == pill.recordName
    }
    
    var body: some View {
        GeometryReader { metrics in
            HStack {
                Text(DateFormatter.localizedString(from: self.pill.takenAt, dateStyle: .medium, timeStyle: .none))
                    .foregroundColor(self.pill.takenAt.in(region: Region.local).isToday ? Color.primary : Color.secondary)
                    .font(Font.subheadline.weight(.light))
                Text(DateFormatter.localizedString(from: self.pill.takenAt, dateStyle: .none, timeStyle: .short))
                    .foregroundColor(self.pill.takenAt.in(region: Region.local).isToday ? Color.primary : Color.secondary)
                    .font(Font.system(size: 24))
            }.frame(width: metrics.size.width)
        }.background(self.isSelected ? Color.secondary : Color.clear)
//            .onTapGesture {
//                withAnimation {
//                    if self.isSelected {
//                        self.selection = nil
//                    } else {
//                        self.selection = self.pill.recordName
//                    }
//                }
//        }
    }
}

struct ItemView_Previews: PreviewProvider {
    @State static var selection: String? = nil
    static var previews: some View {
        ItemView(selection: $selection, pill: DummyDb().all[0])
    }
}
