//
//  ContentView.swift
//  ListSectionBug
//
//  Created by Jeremy Gale on 2020-05-29.
//  Copyright © 2020 Jeremy Gale. All rights reserved.
//

import SwiftUI

enum ListItemType: String, CaseIterable {
    case even = "Even"
    case odd = "Odd"
}

struct ListItem: Identifiable {
    var id = UUID()
    var title: String
    var type: ListItemType
}

struct ListSection: Identifiable {
    var id = UUID()
    var name: String
    var items: [ListItem] = []
}

class ViewModel: ObservableObject {
    @Published var sections: [ListSection] = []
    
    var items: [ListItem] = []
    
    init() {
        items = [
            ListItem(title: "First Item", type: .even),
            ListItem(title: "Second Item", type: .odd),
            ListItem(title: "Third Item" , type: .even),
            ListItem(title: "Fourth Item" , type: .odd),
        ]
        sortItemsIntoSection()
    }
    
    func sortItemsIntoSection() {
        var sections: [ListSection] = []
        var evenSection = ListSection(name: "Even Items")
        var oddSection = ListSection(name: "Odd Items")

        for item in items {
            switch item.type {
            case .even:
                evenSection.items.append(item)
            case .odd:
                oddSection.items.append(item)
            }
        }
        
        for section in [evenSection, oddSection] {
            if !section.items.isEmpty {
                sections.append(section)
            }
        }
        
        self.sections = sections
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    
    @State var showSheet = false
    @State var shownListItem: ListItem = ListItem(title: "", type: .even) // throwaway item to initialize
    
    var body: some View {
        // Use id: \.name for smooth swipe-to-delete but buggy refreshing :(
        List {
            ForEach(self.viewModel.sections, id: \.name) { section in
                Section(header: Text(section.name)) {
                    ForEach(section.items) { item in
                        ItemCell(item: item)
                            .onTapGesture {
                                self.shownListItem = item
                                self.showSheet.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: self.$showSheet) {
            ItemDetailView(viewModel: DetailViewModel(item: self.shownListItem))
        }
        .listStyle(GroupedListStyle())
    }
}

class DetailViewModel: ObservableObject {
    @Published var item: ListItem
    
    init(item: ListItem) {
        self.item = item
    }
}

struct ItemDetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $viewModel.item.type, label: Text("Item Type")) {
                    ForEach(ListItemType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
        }
    }
}

struct ItemCell: View {
    let item: ListItem
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                Text(item.type.rawValue)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
        }
        .contentShape(Rectangle()) // Needed so you can tap anywhere on the cell
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
