//
//  ItemRepository.swift
//  ListSectionBug
//
//  Created by Jeremy Gale on 2020-05-29.
//  Copyright © 2020 Jeremy Gale. All rights reserved.
//

import Foundation

class ItemRepository {
    static let shared = ItemRepository(items: [
        ListItem(title: "Item A", type: .even),
        ListItem(title: "Item B", type: .even),
        ListItem(title: "Item C" , type: .odd),
        ListItem(title: "Item D" , type: .odd),
    ])
    
    @Published var items: [ListItem] = []
    
    init(items: [ListItem]) {
        self.items = items
    }
    
    func getItemFromID(_ itemId: UUID) -> ListItem? {
        return items.first(where: { $0.id == itemId })
    }
    
    func updateItem(itemId: UUID, toType type: ListItemType) {
        guard let itemIndex = items.firstIndex(where: { $0.id == itemId }) else { return }
        
        items[itemIndex].type = type
    }
}
