//
//  ContentView.swift
//  ListSectionBug
//
//  Created by Jeremy Gale on 2020-05-29.
//  Copyright © 2020 Jeremy Gale. All rights reserved.
//

import SwiftUI
import Combine

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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        ItemRepository.shared.$items.map { self.sortItemsIntoSection(items: $0) }
        .assign(to: \.sections, on: self)
        .store(in: &cancellables)
    }
    
    func sortItemsIntoSection(items: [ListItem]) -> [ListSection] {
         return [
            ListSection(name: "Even Items", items: items.filter { $0.type == .even }),
            ListSection(name: "Odd Items", items: items.filter { $0.type == .odd })
        ]
    }
}


struct ListView: View {
    @ObservedObject var viewModel = ViewModel()
    
    @State var showSheet = false
    @State var shownListItemID: UUID = UUID() // throwaway UUID to initialize
    
    var body: some View {
        List {
            // Buggy:
            //   ForEach(self.viewModel.sections, id: \.name) { section in
            // Works, but causes other problems:
            //   ForEach(self.viewModel.sections) { section in
            ForEach(self.viewModel.sections, id: \.name) { section in
                Section(header: Text(section.name)) {
                    ForEach(section.items) { item in
                        ItemCell(item: item)
                            .onTapGesture {
                                self.shownListItemID = item.id
                                self.showSheet.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: self.$showSheet) {
            ItemDetailView(viewModel: DetailViewModel(listItemID: self.shownListItemID))
        }
        .listStyle(GroupedListStyle())
    }
}

struct ItemCell: View {
    let item: ListItem
    
    init(item: ListItem) {
        // Can set a breakpoint in here to see that it only gets hit 3 times (not including Item C)
        self.item = item
    }
    
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
        ListView()
    }
}
