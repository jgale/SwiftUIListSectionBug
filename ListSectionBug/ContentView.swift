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
        
        return sections
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    
    @State var showSheet = false
    @State var shownListItem: ListItem = ListItem(title: "", type: .even) // throwaway item to initialize
    
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
    
    private var cancellables = Set<AnyCancellable>()
    
    init(item: ListItem) {
        self.item = item
        
        $item
        .dropFirst()
        .sink { item in
            ItemRepository.shared.updateItem(itemId: item.id, toType: item.type)
        }
        .store(in: &cancellables)
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
            .navigationBarTitle("\(viewModel.item.title)", displayMode: .inline)
        }
    }
}

struct ItemCell: View {
    let item: ListItem
    
    init(item: ListItem) {
        // Can set a breakpoint in here to see that it only gets hit 3 times (not including Item B)
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
        ContentView()
    }
}
