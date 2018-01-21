//
//  ItemCell.swift
//  Homepwner
//
//  Created by Rohit Pal on 20/01/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit

struct ItemCellModel {
    let model: ItemModel

    var itemName: String {
        return model.name
    }
    var serialNumber: String? {
        return model.serialNumber
    }
    var value: String {
        return self.numberFomatter.string(from: model.price) ?? "--"
    }
    var date: String {
        return self.dateFormatter.string(from: model.date)
    }

    var itemKey: String {
        return self.model.itemKey
    }

    let numberFomatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(itemModel model: ItemModel) {
        self.model = model
    }
}

class ItemCell: UITableViewCell {
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var serialNumber: UILabel!
    @IBOutlet private weak var value: UILabel!

    func setupCell(cellModel model: ItemCellModel) {
        itemName.text = model.itemName
        serialNumber.text = model.serialNumber
        value.text = model.value

        updateLabel()
    }

    func updateLabel() {
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        itemName.font = bodyFont
        value.font = bodyFont
        let caption1Font = UIFont.preferredFont(forTextStyle: .caption1)
        serialNumber.font = caption1Font
    }
}
