//
//  TabBar.swift
//  ListSectionBug
//
//  Created by Jeremy Gale on 2020-05-29.
//  Copyright © 2020 Jeremy Gale. All rights reserved.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            ListView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Tab 1")
            }
            .tag(0)
            Text("Tab 2")
                .tabItem {
                    Image(systemName: "house")
                    Text("Tab 2")
            }
            .tag(1)
        }
    }
}
