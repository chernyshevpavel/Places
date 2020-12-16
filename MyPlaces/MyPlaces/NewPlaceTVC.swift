//
//  NewPlaceTVC.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 21.11.2020.
//

import UIKit


class NewPlaceTVC: UITableViewController {
    
    var currentPlace: Place?
    private var isImageChanged = false

    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameOfPlace: UITextField!
    @IBOutlet weak var locationOfPlace: UITextField!
    @IBOutlet weak var typeOfPlace: UITextField!
    @IBOutlet weak var ratingOfPlace: RatingControl!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveBtn.isEnabled = false
        nameOfPlace.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        setupEditScreen()
    }

    // MARK: Tavle view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let alertSheet = UIAlertController(title: nil,
                                               message: nil,
                                               preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _  in
                self?.imagePicker(sourceType: .camera)
            }
            let cameraIcon = UIImage(systemName: "camera")
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { [weak self] _ in
                self?.imagePicker(sourceType: .photoLibrary)
            }
            let photoIcon = UIImage(systemName: "photo")
            photo.setValue(photoIcon, forKey: "Image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertSheet.addAction(camera)
            alertSheet.addAction(photo)
            alertSheet.addAction(cancel)
            
            present(alertSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showMap" else { return }
        guard let mapVC = segue.destination as? MapViewController else { return }
        mapVC.place.name = nameOfPlace.text ?? ""
        mapVC.place.type = typeOfPlace.text
        mapVC.place.location = locationOfPlace.text
        mapVC.place.rating = Double(ratingOfPlace.rating)
    }
    
    func savePlace() {
        var imageData: Data?
        if isImageChanged {
            imageData = imageOfPlace.image?.pngData()
        } else {
            imageData = UIImage(named: "imagePlaceholder.png")?.pngData()
        }
        
        let place = Place(name: nameOfPlace.text ?? "", location: locationOfPlace.text, type: typeOfPlace.text, imageData: imageData, rating: Double(ratingOfPlace.rating))
        
        let storageManager = StorageManager()
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = place.name
                currentPlace?.location = place.location
                currentPlace?.type = place.type
                currentPlace?.imageData = place.imageData
                currentPlace?.rating = place.rating
            }
        } else {
            storageManager.savePlace(place)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {
                return
            }
            setupEditNavigationBar()
            imageOfPlace.image = image
            isImageChanged = true
            imageOfPlace.contentMode = .scaleAspectFit
            imageOfPlace.backgroundColor = .black
            nameOfPlace.text = currentPlace?.name
            locationOfPlace.text = currentPlace?.location
            typeOfPlace.text = currentPlace?.type
            ratingOfPlace.rating = Int(currentPlace?.rating ?? 0)
        }
    }
    
    private func setupEditNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveBtn.isEnabled = true
        guard let topItem = navigationController?.navigationBar.topItem else {
            return
        }
        topItem.backBarButtonItem = UIBarButtonItem(title: "", image: nil, primaryAction: nil, menu: nil)
    }
    
    @IBAction func cancleTaped(_ sender: Any) {
        dismiss(animated: true)
    }
}
// MARK: Text field delegate
extension NewPlaceTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func nameChanged() {
        self.saveBtn.isEnabled = nameOfPlace.hasText
    }
}

// MARK: UIImagePicker
extension NewPlaceTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.isImageChanged = true
        self.imageOfPlace.image = info[.editedImage] as? UIImage
        self.imageOfPlace.contentMode = .scaleAspectFill
        self.imageOfPlace.clipsToBounds = true
        dismiss(animated: true)
    }
}
