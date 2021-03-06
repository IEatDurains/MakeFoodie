//
//  ViewPostViewController.swift
//  MakeFoodie
//
//  Created by Chen Kang Ning on 7/7/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MapKit

class ViewPostViewController: UIViewController, MKMapViewDelegate {
    // Labels + fav button
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // Location mapView
    @IBOutlet weak var locationMap: MKMapView!
    
    // Buttons
    @IBOutlet weak var orderButton: UIButton!
    
    // Delete bar button
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    //create recipe and view recipe button
    @IBOutlet weak var createRecipeButton: UIButton!
    @IBOutlet weak var viewRecipeButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    
    var post: Post?
    var userList: [User] = []
    var postList: [Post] = []
    var recipeList: [Recipe] = []
    var username: String = ""
    var nameText = ""
    var currPostId: String = ""
    var currentUser: String = ""
    var favourite:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RecipeDetailViewController.tapFunction))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(tap)
        
        locationMap.delegate = self
        
        // Set color to buttons
        orderButton.tintColor = UIColor.orange
        createRecipeButton.tintColor = UIColor.orange
        viewRecipeButton.tintColor = UIColor.orange
        routeButton.tintColor = UIColor.orange
        
        // Check if current logged in user is the user that created the post
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uidd: String = user.uid
                currentUser = user.uid
                // If current user is not the user who created the post remove edit and delete button
                if (uidd != self.post?.uid) {
                    self.navigationItem.rightBarButtonItems = nil
                    //hide create recipe button if post does not belong to user
                    self.createRecipeButton.isHidden = true
                }
                else {
                    // Hide follow btn if current user and post creator is the same
                    favouriteButton.isHidden = true
                    //check for postId

                }
                checkRecipesForPostId()
            }
        }
        checkIfFollowedPost()
        loadPosts()
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "viewProfile") as! ProfileViewController

        newViewController.visitorUID = post?.uid as! String
        newViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    //function to load recipes and check if postId exists
    func checkRecipesForPostId() {
        DataManager.loadRecipes() {
            recipeListFromFirestore in

            self.recipeList = recipeListFromFirestore
            if (self.recipeList.isEmpty) {
                //hide view recipe
                print("empty")
                self.viewRecipeButton.isHidden = true
                //if belong to user
                if (self.currentUser == self.post?.uid) {
                    //show createRecipeButton
                    self.createRecipeButton.isHidden = false
                }
                else { //if post does not belong
                    self.createRecipeButton.isHidden = true
                }
                
            }
            else { //if list not empty
                for i in self.recipeList {
                    if (i.postId == self.post?.id) { //if already exists
                        print("exists")
                        //hide createRecipeButton
                        self.createRecipeButton.isHidden = true
                        //show viewRecipeButton
                        self.viewRecipeButton.isHidden = false
                        //if found, break out of the loop
                        break
                    }
                    else { //if it doesnt exist
                        print("not")
                        //if post belongs to user (and does not exist)
                        if (self.currentUser == self.post?.uid) {
                            //show createRecipeButton
                            self.createRecipeButton.isHidden = false
                        }
                        else { //if post does not belong
                            self.createRecipeButton.isHidden = true
                        }
                        self.viewRecipeButton.isHidden = true
                    }
                }
            }
            
        }
        
    }
    
    // Function that loads data from Firestore and refreshes tableView
    func loadPosts() {
        DataManager.loadPosts ()
        {
            postListFromFirestore in

            // Assign list to list from Firestore
            self.postList = postListFromFirestore
            
            for i in 0 ..< self.postList.count {
                // Find the post based on Id
                if self.postList[i].id == self.currPostId {
                    // For edit, set labels to new edited data
                    self.titleLabel.text = self.postList[i].title
                    self.priceLabel.text = "$" + String(self.postList[i].price)
                    self.postImageView.image = self.postList[i].thumbnail.getImage()
                    self.timeLabel.text = self.postList[i].startTime + " to " + self.postList[i].endTime
                    self.descLabel.text = self.postList[i].desc
                    self.categoryLabel.text = self.postList[i].category
                    
                    // Set post to updated values for edit + time check
                    self.post?.title = self.postList[i].title
                    self.post?.price = self.postList[i].price
                    self.post?.thumbnail = self.postList[i].thumbnail
                    self.post?.startTime = self.postList[i].startTime
                    self.post?.endTime = self.postList[i].endTime
                    self.post?.desc = self.postList[i].desc
                    self.post?.category = self.postList[i].category
                    self.post?.latitude = self.postList[i].latitude
                    self.post?.longitude = self.postList[i].longitude
                    self.post?.locationName = self.postList[i].locationName
                    self.post?.locationAddr = self.postList[i].locationAddr
                                        
                    // Remove existing annotations
                    self.locationMap.removeAnnotations(self.locationMap.annotations)
                    
                    // Set location map
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)  // Zoom level
                    let coordinates:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.postList[i].latitude, longitude: self.postList[i].longitude)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.locationMap.setRegion(region, animated: true)
                    
                    // Place annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    annotation.title = self.postList[i].locationName
                    annotation.subtitle = self.postList[i].locationAddr
                    self.locationMap.addAnnotation(annotation)

                    // Display annotation
                    self.locationMap.selectAnnotation(self.locationMap.annotations[0], animated: true)
                }
            }
            
            self.compareTime()
        }
    }
    
    func compareTime() {
        // Check if time is beyond or before current time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current

        // Convert start and end time to date
        let startingTime = dateFormatter.date(from: self.post!.startTime)
        let endingTime = dateFormatter.date(from: self.post!.endTime)
        
        // Get current date
        let now = dateFormatter.date(from: dateFormatter.string(from: Date()))
                
        // Compare timing
        // If start or end time and current time same
        if startingTime?.compare(now!) == .orderedSame || endingTime?.compare(now!) == .orderedSame {
            self.orderButton.isHidden = false
        }
        else {
            if startingTime?.compare(now!) == .orderedAscending {
                if endingTime?.compare(now!) == .orderedAscending {
                    // Disable order button if beyond
                    self.orderButton.isHidden = true
                }
                else {
                    // Enable if still within time period
                    self.orderButton.isHidden = false
                }
            }
            else {
                // Disable order button if before
                self.orderButton.isHidden = true
            }
        }
    }
    
    // check if the logged in user has a record that they followed this post
    func checkIfFollowedPost() {

        DataManager.retrieveRecipeAndPosttFollowData(followeruid: currentUser, following: post!.id, type: "post") { (result) in
            let documentFound: Bool = result
            
            if documentFound
            {
                // if record found, change button image to filld heart
                self.favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                self.favourite = true
            }
            else
            {
                // just in case
                // if record not found, change button image to hollow heart
                self.favouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                self.favourite = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // This behaves like the Table View's dequeue re-usable cell.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        // If there aren't any reusable views to dequeue, we will have to create a new one.
        if annotationView == nil
        {
            let pinAnnotationView = MKPinAnnotationView(annotation: nil, reuseIdentifier: "pin")
            annotationView = pinAnnotationView
        }
        
        // Assign the annotation to the pin so that iOS knows where to position it in the map.
        annotationView?.annotation = annotation
        
        // Set button to right of annotation and pop up when clicked
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    // This function is triggered when the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        titleLabel.text = post?.title
        postImageView.image = post?.thumbnail.getImage()
        DataManager.loadUser() {
            userListFromFirestore in
            self.userList = userListFromFirestore
            for i in self.userList {
                if (i.uid == self.post?.uid) {
                    self.usernameLabel.text = i.username
                }
            }
        }
        
        if post?.price != nil {
            priceLabel.text = "$\(post!.price)"
        }
        else {
            priceLabel.text = "Not available"
        }
        
        if post?.startTime != nil {
            if post?.endTime != nil {
                // Set label
                timeLabel.text = post!.startTime + " to " + post!.endTime
                
                compareTime()
            }
            else {
                timeLabel.text = "Not available"
            }
        }
        else {
            timeLabel.text = "Not available"
        }
        
        descLabel.text = post?.desc
        categoryLabel.text = post?.category
        
        checkRecipesForPostId()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        compareTime()
    }
    
    // Click on trash icon
    @IBAction func deleteButtonPressed(_ sender: Any) {
        // Alert controller
        let alertController = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
               
        // Confirm action
        let confirm = UIAlertAction(title: "Delete", style: .destructive) {
            (action:UIAlertAction!) in
            
            // Delete post
            DataManager.deletePost(self.post!)
            
            // Delete followers
            DataManager.deleteAllfollowers(id: self.post!.id, type: "post")
            
            //check if recipe exists
            for i in self.recipeList {
                if (i.postId == self.post!.id) {
                    //edit postId to "" in the recipe
                    DataManager.insertOrReplaceRecipe(Recipe(recipeID: i.recipeID, title: i.title, desc: i.desc, ingredients: i.ingredients, instructions: i.instructions, thumbnail: i.thumbnail, reviews: i.reviews, uid: i.uid, postId: ""))
                }
                else {}
            }
            
            if (self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].restorationIdentifier == "PostsTableViewController") {
                // Reload post in tableView
                let parent = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2] as! PostsTableViewController
                parent.loadPosts()
            }
            // Go back to tableView
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirm)
               
        // Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
            (action:UIAlertAction!) in
            
            print("Delete post cancelled");
        }
        alertController.addAction(cancel)
               
        // Present alertController
        self.present(alertController, animated: true, completion:nil)
    }
    
    
    // activate when follow button is pressed
    @IBAction func FavouriteButtonPressed(_ sender: UIButton) {
        
        if favourite == false
        {
            favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            favourite = true
            DataManager.insertRecipeAndPosttFollowData(followeruid: currentUser, following: post!.id, type: "post")
            
        }
        else
        {
            favouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            favourite = false
            DataManager.deleteRecipeAndPosttFollowData(followeruid: currentUser, following: post!.id, type: "post")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
    @IBAction func OrderNavigation(_ sender: Any) {
        nameText = titleLabel.text!
        performSegue(withIdentifier: "orderreq", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditPost")
        {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
            let editPostViewController = segue.destination as! EditPostViewController
            if (post != nil) {
                // Set the post object to selected post
                let currentPost = post!
                editPostViewController.post = currentPost
            }
        }
        
        if (segue.identifier == "GetDirections") {
            let routeViewController = segue.destination as! RouteViewController
            if (post != nil) {
                let lat = post!.latitude
                let lng = post!.longitude
                let locName = post!.locationName
                let locAddr = post!.locationAddr
                routeViewController.destLat = lat
                routeViewController.destLng = lng
                routeViewController.destName = locName
                routeViewController.destAddr = locAddr
            }
        }
        
        if (segue.identifier == "orderreq"){
            let vc = segue.destination as! OrderReqViewController
            vc.finalName = self.nameText
        }
        
        if (segue.identifier == "createRecipe") {
            let destView = segue.destination as! CreateRecipeViewController
            if (self.post != nil) {
                destView.post = self.post
                destView.curruid = self.currentUser
            }
        }
        
        if (segue.identifier == "viewRecipe") {
            UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "RecipesTableViewController") as! RecipesTableViewController
            //newViewController.selectedIndex = 2
            //self.navigationController?.addChild(newViewController)
            
            let destView = segue.destination as! RecipeDetailViewController
            if (self.post != nil) {
                //assign destView.recipe by searching through recipeList for postId
                for i in self.recipeList {
                    //check if postId matches
                    if (i.postId == self.post!.id) {
                        destView.recipe = Recipe(recipeID: i.recipeID, title: i.title, desc: i.desc, ingredients: i.ingredients, instructions: i.instructions, thumbnail: i.thumbnail, reviews: i.reviews, uid: i.uid, postId: i.postId)
                        //if found, break out of the loop
                        break
                    }
                    else {
                    }
                }
                destView.post = self.post
                destView.curruid = self.currentUser

            }
        }
    }
}
