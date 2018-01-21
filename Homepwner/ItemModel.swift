//
//  ItemModel.swift
//  Homepwner
//
//  Created by Rohit Pal on 21/01/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit

class ItemModel: NSObject, NSCoding {
    let itemKey: String
    var name: String
    var serialNumber: String?
    var price: NSNumber
    let date: Date
    init(itemKey: String = UUID().uuidString, name: String, serialNumber: String?, price: NSNumber, date: Date = Date()) {
        self.itemKey = itemKey
        self.name = name
        self.serialNumber = serialNumber
        self.price = price
        self.date = date
    }

    convenience init(random: Bool = false) {
        if random {
            let adjective: [String] = ["Fluffy", "Rusty", "Shiny", "Fragile"]
            let noun: [String] = ["Bear", "Mac", "Spork", "Bottle" ]
            var index = arc4random_uniform(UInt32(adjective.count))
            let randomAdjective = adjective[Int(index)]
            index = arc4random_uniform(UInt32(noun.count))
            let randomNoun = noun[Int(index)]
            let randomName = "\(randomAdjective) \(randomNoun)"
            let randomPrice = NSNumber(value: arc4random_uniform(100))
            let randomSerialNumber = UUID().uuidString.components(separatedBy: "-").first!
            self.init(name: randomName, serialNumber: randomSerialNumber, price: randomPrice)
        } else {
            self.init(name: "", serialNumber: nil, price: 0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        serialNumber = aDecoder.decodeObject(forKey: "serialNumber") as? String
        itemKey = (aDecoder.decodeObject(forKey: "itemKey") as? String) ??  UUID().uuidString
        name = (aDecoder.decodeObject(forKey: "name") as? String) ?? ""
        price = (aDecoder.decodeObject(forKey: "price") as? NSNumber) ?? 0
        date = (aDecoder.decodeObject(forKey: "date") as? Date) ?? Date()
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(itemKey, forKey: "itemKey")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(serialNumber, forKey: "serialNumber")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(date, forKey: "date")
    }

}

class ImageStore {
    private static let cache: NSCache = NSCache<NSString, UIImage>()

    static private func getImageUrl(forKey key: String) -> URL? {
        guard let baseurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return baseurl.appendingPathComponent(key)
    }
    static func setImage(image: UIImage, forKey key: NSString) {
        cache.setObject(image, forKey: key)
        guard let url = getImageUrl(forKey: key as String) else {
            return
        }
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            try? data.write(to: url)
        }
    }

    static func image(forKey key: NSString) -> UIImage? {
        if let image = cache.object(forKey: key) {
            return image
        }
        guard let url = getImageUrl(forKey: key as String), let image = UIImage(contentsOfFile: url.path)  else {
            return nil
        }
        cache.setObject(image, forKey: key)
        return image
    }

    static func deleteImage(forKey key: NSString) {
        cache.removeObject(forKey: key)
        guard let url = getImageUrl(forKey: key as String) else {
            return
        }
        try? FileManager.default.removeItem(at: url)
    }
}

