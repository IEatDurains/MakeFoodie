//
//  CreatePostViewController.swift
//  MakeFoodie
//
//  Created by Chen Kang Ning on 5/7/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class CreatePostViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    // Inputs
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var takePicture: UIButton!
    @IBOutlet weak var selectPicture: UIButton!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    // Error messages
    @IBOutlet weak var titleError: UILabel!
    @IBOutlet weak var priceError: UILabel!
    @IBOutlet weak var thumbnailError: UILabel!
    @IBOutlet weak var timeError: UILabel!
    @IBOutlet weak var descError: UILabel!
    
    // String array for categories
    var categoryPickerData : [String] = [
        "Western",
        "Chinese",
        "Indian",
        "Japanese",
        "Korean",
        "Thai",
        "Halal",
        "Vegetarian",
        "Baked Goods",
        "Snacks",
        "Beverages",
        "Others"
    ]
    
    // Create list to contain posts from Firebase
    var postList: [Post] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        descTextView.delegate = self
        
        // Set color to buttons
        takePicture.tintColor = UIColor.orange
        selectPicture.tintColor = UIColor.orange
        
        // Close keyboard when click outside textField
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:))))

        // Set round border for descTextView
        self.descTextView.layer.borderColor = UIColor.black.cgColor
        self.descTextView.layer.borderWidth = 0.3
        self.descTextView.layer.cornerRadius = 6
        
        // If no image in imageView, hide it
        if (self.thumbnailImageView.image == nil)
        {
            self.thumbnailImageView.isHidden = true
        }
        
        // Check if device has a camera
        if !(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            // Hide if not available
            takePicture.isHidden = true
        }
        
        // Hide error messages
        titleError.isHidden = true
        priceError.isHidden = true
        thumbnailError.isHidden = true
        timeError.isHidden = true
        descError.isHidden = true
        
        loadPosts()
    }
    
    // Function that loads data from Firestore and refreshes tableView
    func loadPosts() {
        DataManager.loadPosts ()
        {
            postListFromFirestore in

            // Assign list to list from Firestore
            self.postList = postListFromFirestore
        }
    }
    
    @objc func backgroundTap(gesture : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Category PickerView
    
    // Picker view columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // How many items in a list to display for a given component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryPickerData.count
    }
    
    // What to display in picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryPickerData[row]
    }
    
    // MARK: - Image
    
    // Resize thumbnail image
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // Called after selecting or taking picture and place into the imageView then closing the picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage : UIImage = info[.editedImage] as! UIImage
        var resizedImage: UIImage
        
        resizedImage = resizeImage(image: chosenImage, newWidth: 374)
        self.thumbnailImageView.isHidden = false // Ensure imageView is not hidden after selection
        self.thumbnailImageView!.image = resizedImage
        UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil) // Save the image selected/taken by user

        picker.dismiss(animated: true) // Close picker
        
        if (self.thumbnailImageView.image == nil) {
            thumbnailError.isHidden = false
        }
        else {
            thumbnailError.isHidden = true
        }
    }
    
    // User cancels from taking or selecting image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - TextView + TextField Change
    
    // Run if changes made to descTextView
    func textViewDidChange(_ textView: UITextView) {
        // Check if desc textView is empty (White space + Blank)
        if (descTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            descError.isHidden = false
            descTextView.layer.borderColor = UIColor.red.cgColor
            descTextView.layer.borderWidth = 1.0
            descTextView.layer.cornerRadius = 6
        }
        else {
            descError.isHidden = true
            descTextView.layer.borderColor = UIColor.black.cgColor
            descTextView.layer.borderWidth = 0.3
            descTextView.layer.cornerRadius = 6
        }
    }
    
    // Run when user make changes to the title text field
    @IBAction func titleTextFieldChanged(_ sender: Any) {
        // Check if title textField is empty (White space + Blank)
        if (titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            titleError.isHidden = false
            titleTextField.layer.borderColor = UIColor.red.cgColor
            titleTextField.layer.borderWidth = 1
            titleTextField.layer.cornerRadius = 6
        }
        else {
            titleError.isHidden = true
            titleTextField.layer.borderColor = UIColor.black.cgColor
            titleTextField.layer.borderWidth = 0.3
            titleTextField.layer.cornerRadius = 6
        }
    }
    
    // Run when user make changes to the price text field
    @IBAction func priceTextFieldChanged(_ sender: Any) {
        // Check if price textField is empty (White space + Blank)
        if (priceTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            priceError.text = "Please enter a price."
            priceError.isHidden = false
            priceTextField.layer.borderColor = UIColor.red.cgColor
            priceTextField.layer.borderWidth = 1.0
            priceTextField.layer.cornerRadius = 6
        }
        else {
            // Check for double
            if Double(priceTextField.text!) != nil {
                // Check if textField has decimal
                if (priceTextField.text!.contains(".")) {
                    // If there is decimal place, and after another decimal, show error
                    if (priceTextField.text!.components(separatedBy: ".")[1].contains(".")) {
                        priceError.text = "Please input a valid number."
                        priceError.isHidden = false
                        priceTextField.layer.borderColor = UIColor.red.cgColor
                        priceTextField.layer.borderWidth = 1.0
                        priceTextField.layer.cornerRadius = 6
                    }
                    else {
                        // Else ensure that only 2dp max
                        switch priceTextField.text!.components(separatedBy: ".")[1].count {
                            case 1, 2: // If 1 or 2dp, accept
                                priceError.isHidden = true
                                priceTextField.layer.borderColor = UIColor.black.cgColor
                                priceTextField.layer.borderWidth = 0.3
                                priceTextField.layer.cornerRadius = 6
                            default:  // If 0 or more than 2dp, reject
                                priceError.text = "Maximum of 2 decimal places."
                                priceError.isHidden = false
                                priceTextField.layer.borderColor = UIColor.red.cgColor
                                priceTextField.layer.borderWidth = 1.0
                                priceTextField.layer.cornerRadius = 6
                        }
                    }
                }
                else {
                    priceError.isHidden = true
                    priceTextField.layer.borderColor = UIColor.black.cgColor
                    priceTextField.layer.borderWidth = 0.3
                    priceTextField.layer.cornerRadius = 6
                }
            }
            else {
                priceError.text = "Please input a valid number."
                priceError.isHidden = false
                priceTextField.layer.borderColor = UIColor.red.cgColor
                priceTextField.layer.borderWidth = 1.0
                priceTextField.layer.cornerRadius = 6
            }
        }
    }
    
    // When click on textField, open a datePicker displaying time format to set time
    @IBAction func startTimeTextFieldBeginEditing(_ sender: Any) {
        let timePickerView:UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .time
        startTimeTextField.inputView = timePickerView
        //timePickerView.addTarget(self, action: #selector(startTimePickerSetValue(sender:)), for: .touchCancel)
        timePickerView.addTarget(self, action: #selector(startTimePickerChanged(sender:)), for: .valueChanged) // When value change in datePicker, call function
    }
    
    @IBAction func endTimeTextFieldBeginEditing(_ sender: Any) {
        let timePickerView:UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .time
        endTimeTextField.inputView = timePickerView
        //timePickerView.addTarget(self, action: #selector(endTimePickerSetValue(sender:)), for: .editingDidEndOnExit)
        timePickerView.addTarget(self, action: #selector(endTimePickerChanged(sender:)), for: .valueChanged) // When value change in datePicker call function
    }
    
    // Function to set textField to datePicker time
    @objc func startTimePickerChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        startTimeTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func endTimePickerChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        endTimeTextField.text = dateFormatter.string(from: sender.date)
    }
    
    /* Function to set datePicker time value to textField time
    @objc func startTimePickerSetValue(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        print("1")
        dateFormatter.dateFormat = "h:mm a"
        if (startTimeTextField.text != nil) {
            sender.date = dateFormatter.date(from: startTimeTextField.text!)!
            print("Ran trimming")
        }
        else {
            sender.date = Date()
            startTimeTextField.text = dateFormatter.string(from: sender.date)
            print("empty")
        }
    }
    
    @objc func endTimePickerSetValue(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        print ("2")
        if (endTimeTextField.text != nil) {
            sender.date = dateFormatter.date(from: endTimeTextField.text!)!
            print("trimming end")
        }
        else {
            sender.date = Date()
            endTimeTextField.text = dateFormatter.string(from: sender.date)
            print("empty end")
        }
    }*/
    
    // MARK: - Button actions
    
    // Click on Take Picture
    @IBAction func takePicturePressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true // Allows editing of image
        picker.sourceType = .camera // Use camera
        self.present(picker, animated: true)
    }
    
    // Click on Select Picture
    @IBAction func selectPicturePressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true // Allows editing of image
        picker.sourceType = .photoLibrary // Use image from library
        self.present(picker, animated: true)
    }

    
    // Click cancel button
    @IBAction func cancelButtonPressed(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    // Click save button
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Bool var to check valid creation
        var verified = true
        
        // Check again if title,price,desc is empty (White space + Blank) - If user click save after clicking add icon from prev controller
        // Title check
        if (titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            titleError.isHidden = false
            titleTextField.layer.borderColor = UIColor.red.cgColor
            titleTextField.layer.borderWidth = 1.0
            titleTextField.layer.cornerRadius = 6
            verified = false
        }
        else {
            titleError.isHidden = true
            titleTextField.layer.borderColor = UIColor.black.cgColor
            titleTextField.layer.borderWidth = 0.3
            titleTextField.layer.cornerRadius = 6
        }
        
        // Price check
        if (priceTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            priceError.text = "Please enter a price."
            priceError.isHidden = false
            priceTextField.layer.borderColor = UIColor.red.cgColor
            priceTextField.layer.borderWidth = 1.0
            priceTextField.layer.cornerRadius = 6
            verified = false
        }
        else {
            // Check for double
            if Double(priceTextField.text!) != nil {
                // Check if textField has decimal
                if (priceTextField.text!.contains(".")) {
                    // If there is decimal place, and after another decimal, show error
                    if (priceTextField.text!.components(separatedBy: ".")[1].contains(".")) {
                        priceError.text = "Please input a valid number."
                        priceError.isHidden = false
                        priceTextField.layer.borderColor = UIColor.red.cgColor
                        priceTextField.layer.borderWidth = 1.0
                        priceTextField.layer.cornerRadius = 6
                        verified = false
                    }
                    else {
                        // Else ensure that only 2dp max
                        switch priceTextField.text!.components(separatedBy: ".")[1].count {
                            case 1, 2: // If 1 or 2dp, accept
                                priceError.isHidden = true
                                priceTextField.layer.borderColor = UIColor.black.cgColor
                                priceTextField.layer.borderWidth = 0.3
                                priceTextField.layer.cornerRadius = 6
                            default:  // If 0 or more than 2dp, reject
                                priceError.text = "Maximum of 2 decimal places."
                                priceError.isHidden = false
                                priceTextField.layer.borderColor = UIColor.red.cgColor
                                priceTextField.layer.borderWidth = 1.0
                                priceTextField.layer.cornerRadius = 6
                                verified = false
                        }
                    }
                }
                else {
                    priceError.isHidden = true
                    priceTextField.layer.borderColor = UIColor.black.cgColor
                    priceTextField.layer.borderWidth = 0.3
                    priceTextField.layer.cornerRadius = 6
                }
            }
            else {
                priceError.text = "Please input a valid number."
                priceError.isHidden = false
                priceTextField.layer.borderColor = UIColor.red.cgColor
                priceTextField.layer.borderWidth = 1.0
                priceTextField.layer.cornerRadius = 6
                verified = false
            }
        }
        
        // Start time check
        if (startTimeTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            timeError.text = "Start time not chosen."
            timeError.isHidden = false
            startTimeTextField.layer.borderColor = UIColor.red.cgColor
            startTimeTextField.layer.borderWidth = 1.0
            startTimeTextField.layer.cornerRadius = 6
            verified = false
        }
        else {
            timeError.isHidden = true
            startTimeTextField.layer.borderColor = UIColor.black.cgColor
            startTimeTextField.layer.borderWidth = 0.3
            startTimeTextField.layer.cornerRadius = 6
        }
        
        // End time check
        if (endTimeTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            timeError.text = "End time not chosen."
            timeError.isHidden = false
            endTimeTextField.layer.borderColor = UIColor.red.cgColor
            endTimeTextField.layer.borderWidth = 1.0
            endTimeTextField.layer.cornerRadius = 6
            verified = false
        }
        else {
            timeError.isHidden = true
            endTimeTextField.layer.borderColor = UIColor.black.cgColor
            endTimeTextField.layer.borderWidth = 0.3
            endTimeTextField.layer.cornerRadius = 6
        }
        
        // Check if both not nil
        if (startTimeTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == false && endTimeTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == false) {
            // Check if they have the same timing
            if (startTimeTextField.text == endTimeTextField.text) {
                timeError.text = "Time has to differ."
                timeError.isHidden = false
                startTimeTextField.layer.borderColor = UIColor.red.cgColor
                startTimeTextField.layer.borderWidth = 1.0
                startTimeTextField.layer.cornerRadius = 6
                
                endTimeTextField.layer.borderColor = UIColor.red.cgColor
                endTimeTextField.layer.borderWidth = 1.0
                endTimeTextField.layer.cornerRadius = 6
                verified = false
            }
            else {
                timeError.isHidden = true
                startTimeTextField.layer.borderColor = UIColor.black.cgColor
                startTimeTextField.layer.borderWidth = 0.3
                startTimeTextField.layer.cornerRadius = 6
                
                endTimeTextField.layer.borderColor = UIColor.black.cgColor
                endTimeTextField.layer.borderWidth = 0.3
                endTimeTextField.layer.cornerRadius = 6
            }
        }
        else {
            if (startTimeTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true && endTimeTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
                timeError.text = "No time chosen."
                timeError.isHidden = false
                startTimeTextField.layer.borderColor = UIColor.red.cgColor
                startTimeTextField.layer.borderWidth = 1.0
                startTimeTextField.layer.cornerRadius = 6
                
                endTimeTextField.layer.borderColor = UIColor.red.cgColor
                endTimeTextField.layer.borderWidth = 1.0
                endTimeTextField.layer.cornerRadius = 6
                verified = false
            }
        }
        
        // Desc check
        if (descTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty == true) {
            descError.isHidden = false
            descTextView.layer.borderColor = UIColor.red.cgColor
            descTextView.layer.borderWidth = 1.0
            descTextView.layer.cornerRadius = 6
            verified = false
        }
        else {
            descError.isHidden = true
            descTextView.layer.borderColor = UIColor.black.cgColor
            descTextView.layer.borderWidth = 0.3
            descTextView.layer.cornerRadius = 6
        }
        
        // Thumbnail check
        if (self.thumbnailImageView.image == nil) {
            thumbnailError.isHidden = false
            verified = false
        }
        else {
            thumbnailError.isHidden = true
        }
        
        // Check if valid
        if (verified == true) {
            // Selected row of picker view
            let row = categoryPickerView.selectedRow(inComponent: 0)
            // Get data selected from picker data
            let selectedCategory = categoryPickerData[row]

            let viewControllers = self.navigationController?.viewControllers
            let parent = viewControllers?[0] as! PostsTableViewController
            let priceValue = Double(priceTextField.text!)
            
            // Set random string
            let ref = db.collection("post")
            let docId = ref.document().documentID
            
            let post:Post = Post(id: docId, title: titleTextField.text!, price: priceValue!, startTime: startTimeTextField.text!, endTime: endTimeTextField.text!, desc: descTextView.text!, thumbnail: Post.Image.init(withImage: thumbnailImageView.image!), category: selectedCategory, uid: parent.curruid)
            
            DataManager.insertOrEditPost(post) {
                parent.loadPosts()
            }
            
            // Redirect back to tableView
            self.navigationController?.popViewController(animated: true)
        }
    }
}
