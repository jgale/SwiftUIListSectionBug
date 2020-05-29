//
//  ItemDetailView.swift
//  ListSectionBug
//
//  Created by Jeremy Gale on 2020-05-29.
//  Copyright © 2020 Jeremy Gale. All rights reserved.
//

import SwiftUI
import Combine

class DetailViewModel: ObservableObject {
    @Published var item: ListItem
    
    private var cancellables = Set<AnyCancellable>()
    
    init(listItemID: UUID) {
        guard let item = ItemRepository.shared.getItemFromID(listItemID) else {
            fatalError("Could not find the listItemID specified")
        }
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
