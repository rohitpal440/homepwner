//
//  ItemListController.swift
//  Homepwner
//
//  Created by Rohit Pal on 20/01/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit
private let reuseIdentifier = "ItemCell"
class ItemListController: UITableViewController {
    private var dataSource: [ItemCellModel] = []
    var viewModel: ItemListViewModel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = 62
        tableView.rowHeight = UITableViewAutomaticDimension
        viewModel = ItemListViewModel()
        dataSource = viewModel.getDataSource()
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ItemCell
        cell.setupCell(cellModel: dataSource[indexPath.row])
        return cell
    }

     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
         // Delete the row from the data source
            ImageStore.deleteImage(forKey: dataSource[indexPath.row].itemKey as NSString)
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
         }
     }

     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if (fromIndexPath == to) {
            return
        }
        let item = dataSource[fromIndexPath.row]
        dataSource.remove(at: fromIndexPath.row)
        dataSource.insert(item, at: to.row)
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemDetailController = storyboard?.instantiateViewController(withIdentifier: "ItemDetailController") as? ItemDetailController {
            let cellModel = dataSource[indexPath.row]
            itemDetailController.updateViewModel(itemModel: cellModel.model)
            self.navigationController?.pushViewController(itemDetailController, animated: true)
        }
    }

    @IBAction func addItem(_ sender: UIBarButtonItem) {
        self.dataSource.append(viewModel.getRandomItem())
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: dataSource.count - 1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }

    @objc func saveChanges() {
        if self.viewModel.save(items: dataSource) {
            print("Successfully saved data")
        } else {
            print("Failed to save changes")
        }
    }
}

class ItemListViewModel {
    func getDataSource() -> [ItemCellModel] {
        var dataSource: [ItemCellModel] = []
        if let itemModels = NSKeyedUnarchiver.unarchiveObject(withFile: path()!) as? [ItemModel] {
            for model in itemModels {
                dataSource.append(ItemCellModel(itemModel: model))
            }
        } else {
            for _ in 0...4 {
                dataSource.append(getRandomItem())
            }
        }
        return dataSource
    }

    func path() -> String? {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let path = documentsPath.appending("/items")
        return path
    }

    func save(items: [ItemCellModel]) -> Bool {
        let itemModels = items.map{$0.model}
        return NSKeyedArchiver.archiveRootObject(itemModels, toFile: path()!)
    }

    func getRandomItem() -> ItemCellModel {
        return ItemCellModel(itemModel: ItemModel(random: true))
    }
}
