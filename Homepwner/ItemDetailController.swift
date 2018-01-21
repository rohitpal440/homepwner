//
//  ItemDetailController.swift
//  Homepwner
//
//  Created by Rohit Pal on 20/01/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit

struct ItemDetailViewModel {
    private var model: ItemModel
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

    func getItemName() -> String {
        return model.name
    }

    func getItemSerialNumber() -> String? {
        return model.serialNumber
    }

    func getItemPrice() -> String {
        return model.price.stringValue
    }

    func getItemCreationDate() -> String {
        return dateFormatter.string(from: model.date)
    }

    func getItemKey() -> String {
        return model.itemKey
    }

    func update(name: String) {
        model.name = name
    }

    func update(price: String) {
        if let value = Double(price) {
            model.price = NSNumber(value: value)
        }
    }

    func update(serialNumber number: String?) {
        model.serialNumber = number ?? "--"
    }
}

class ItemDetailController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var serialNumberTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!

    var viewModel: ItemDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }

    func updateView() {
        self.title = viewModel.getItemName()
        nameTextField.text = viewModel.getItemName()
        serialNumberTextField.text = viewModel.getItemSerialNumber()
        itemPriceTextField.text = viewModel.getItemPrice()
        dateCreated.text = viewModel.getItemCreationDate()
        if let image = ImageStore.image(forKey: viewModel.getItemKey() as NSString) {
            self.itemImageView.image = image
        }
    }

    func updateViewModel(itemModel model: ItemModel) {
        self.viewModel = ItemDetailViewModel(itemModel: model)
    }

    @IBAction func didTapBackground(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func saveDetails(_ sender: UIBarButtonItem) {
        if let name = nameTextField.text, !name.isEmpty {
            viewModel.update(name: name)
        }
        if let price = itemPriceTextField.text, !price.isEmpty {
            viewModel.update(price: price)
        }
        viewModel.update(serialNumber: serialNumberTextField.text)
        updateView()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension ItemDetailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ItemDetailController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.itemImageView.image = image
            ImageStore.setImage(image: image, forKey: viewModel.getItemKey() as NSString)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
