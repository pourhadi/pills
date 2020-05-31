//
//  ItemList.swift
//  pills
//
//  Created by dan on 10/31/19.
//  Copyright © 2019 dan. All rights reserved.
//

import SwiftUI

struct ItemList: View {
    
    @ObservedObject var cloudDb: DB
    
    @Binding var selection: String?
    
    var body: some View {
        return List {
            ForEach(self.cloudDb.all) { pill in
                ZStack {
                    ItemView(selection: self.$selection, pill: pill).frame(height: 50)
                    
                    NavigationLink(destination: EditView(pill: pill, cloudDb: self.cloudDb)) {
                        EmptyView() }.isDetailLink(true)
                }
            }.onDelete { (indexSet) in
                self.cloudDb.delete(indexes: indexSet)
            }
        }
        
    }
}

struct ItemList_Previews: PreviewProvider {
    @State static var selection: String? = nil
    static var previews: some View {
        NavigationView {
            ItemList(cloudDb: DummyDb(), selection: $selection)
        }
    }
}
