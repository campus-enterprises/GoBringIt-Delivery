//
//  RestaurantsHomeViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/17/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

// Show activityIndicator

// download the new always-refreshed data

// check if Realm already has all other Restaurant data

    // if yes, check if there are updates to the data

    // if no, download the data and set all Realm attributes

// Stop activityIndicator



import UIKit
import Alamofire
import Moya
import RealmSwift
import SkeletonView

class RestaurantsHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SkeletonTableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var downloadingView: UIView!
    @IBOutlet weak var downloadingTitle: UILabel!
    @IBOutlet weak var downloadingDetails: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var downloadingImage: UIImageView!
    
    // MARK: - Variables
    
    let refreshControl = UIRefreshControl()
    
    var restaurants = [Restaurant]()
    var backendVersionNumber = -1
    var selectedRestaurant = Restaurant()
    var promotions = [Promotion]()
    var storedOffsets = [Int: CGFloat]()
    var alertMessage = ""
    var alertMessageColor = UIColor()
    var alertMessageLink = ""
    var alertMessageIndex = -1
    var promotionsIndex = -1
    var restaurantsIndex = -1
    var alreadyDisplayedCollectionView = false
    
    var selectedPromotionID = ""
    
    let defaults = UserDefaults.standard // Initialize UserDefaults

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
//        let realm = try! Realm() // Initialize Realm
        
        // Set base index
//        restaurantsIndex = 0
        
        // Setup UI
        setupUI()
        
        // Prepare data for TableView and CollectionView
//        restaurants = realm.objects(Restaurant.self)
//        promotions = realm.objects(Promotion.self)
        
        updateIndices()
        
        // Setup TableView
        setupTableView()
        //checkForCreditCard()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        setCustomBackButton()
        
        // Set logo as title
        let logo = UIImage(named: "NavBarLogo")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit // set imageview's content mode
        self.navigationItem.titleView = imageView
        
        myTableView.isSkeletonable = true
        myTableView.showAnimatedSkeleton()
        
        downloadingView.alpha = 0
        getStartedButton.layer.cornerRadius = Constants.cornerRadius
// If ever credit card entry needs to be forced uncomment these lines
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let creditcardpopup = storyboard.instantiateViewController(withIdentifier: "creditCardCheck")
//        self.present(creditcardpopup, animated: true)
        // Download restaurant data if necessary
        checkForUpdates()
        //checkForCreditCard()
        
    }
    
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 300
        self.myTableView.rowHeight = UITableView.automaticDimension
        
        // Add refresh control capability
        if #available(iOS 10.0, *) {
            myTableView.refreshControl = refreshControl
        } else {
            myTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(RestaurantsHomeViewController.refreshData(refreshControl:)), for: .valueChanged)
    }
    
    @objc func refreshData(refreshControl: UIRefreshControl) {
        //checkForCreditCard()
        checkForUpdates()
    }
    
    func showDownloadingView() {
        
        print("Showing downloading view")
        
//        self.navigationController?.isNavigationBarHidden = true
//        downloadingView.layer.backgroundColor = Constants.green.cgColor
        
        myActivityIndicator.isHidden = false
        myActivityIndicator.startAnimating()
//        downloadingView.alpha = 1
//        downloadingImage.image = UIImage(named: "RestaurantDataImage")
//        downloadingTitle.text = "Downloading restaurant data..."
//        downloadingDetails.text = "This should only take a few seconds, and once it’s done you’ll be able to use most of the app even offline (except ordering of course)!"
//        getStartedButton.alpha = 0

    }
    
    func showFinishedDownloadingView() {
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
//        downloadingView.layer.backgroundColor = Constants.green.cgColor
//        downloadingTitle.text = "Download Complete!"
//        downloadingDetails.text = "You’re all set to use the GoBringIt Delivery app 🍣🍗🍔 Online or offline, you can always view our delicious menu and prepare your order 🎉"
//        getStartedButton.alpha = 1
//        getStartedButton.setTitle("Get Started", for: .normal)
//        getStartedButton.setTitleColor(Constants.green, for: .normal)
        
    }
    
    func showErrorView() {
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
        downloadingView.layer.backgroundColor = Constants.red.cgColor
        downloadingImage.image = UIImage(named: "RestaurantDataErrorImage")
        downloadingTitle.text = "Network Error"
        downloadingDetails.text = "Something went wrong 😱 Make sure you’re connected to the internet and try again!"
        getStartedButton.alpha = 1
        getStartedButton.setTitle("Try Again!", for: .normal)
        getStartedButton.setTitleColor(Constants.red, for: .normal)
        
    }
    
    func updateIndices() {
        
        // TO-DO: Add third check for messages from server (put those in the getbackendnumber call
        
        if alertMessage != "" {
            if promotions.count > 0 {
                alertMessageIndex = 0
                promotionsIndex = 1
                restaurantsIndex = 2
            } else {
                alertMessageIndex = 0
                restaurantsIndex = 1
            }
        } else {
            if promotions.count > 0 {
                promotionsIndex = 0
                restaurantsIndex = 1
            } else {
                restaurantsIndex = 0
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        if downloadingTitle.text == "Download Complete!" {
            
            // Show checking out view
            UIView.animate(withDuration: 0.4, animations: {
                
                self.navigationController?.isNavigationBarHidden = false
                self.downloadingView.alpha = 0
            })
        } else {
            
            showDownloadingView()
//            self.fetchRestaurantData()
        }
    }
    
    
//    @IBAction func unwindfromCreditCard( _ seg: UIStoryboardSegue) {
//    }
//    
//    var user = User()
//
    //Taken care of in check out VC
    
//    func checkForCreditCard() {
//        let realm = try! Realm()
//        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
//        user = realm.objects(User.self).filter(predicate).first!
//        print("Credit Card Method Entered")
//        print("Printing Existing Payment Methods")
//        print(user.paymentMethods)
//        // Setup Moya provider and send network request
//        let provider = MoyaProvider<APICalls>()
//        print("did not reach there")
//        provider.request(.stripeRetrieveCards(userID: user.id)) { result in
//            switch result {
//            case let .success(moyaResponse):
//                do {
//                    print("reached here")
//                    print("Status code: \(moyaResponse.statusCode)")
//                    try moyaResponse.filterSuccessfulStatusCodes()
//                    
//                    let response = try moyaResponse.mapJSON() as! [String: Any]
//                    print(response)
//                    
//                    if let success = response["success"] {
//                       
//                        let creditCards = response["cards"] as! [AnyObject]
//                        if creditCards.isEmpty {
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let creditcardpopup = storyboard.instantiateViewController(withIdentifier: "creditCardCheck")
//                            creditcardpopup.modalPresentationStyle = .fullScreen
//                            self.present(creditcardpopup, animated: true)
//                        }
//                        
//                    }
//                    else{
//                        print("Credit Card Info Not empty")
//                    }
//                    
//                } catch {
//                    // Miscellaneous network error
//                    print("Network Error")
//                }
//            case .failure(_):
//                // Connection failed
//                print("Connection failed")
//            }
//        }
//    }
    
    func checkForUpdates() {
        
        getBackendVersionNumber() {
                            (result: Int) in
                        }
                fetchRestaurantsInfo()
                fetchPromotions() {
                            (result: Int) in
                        }
        
//        let realm = try! Realm() // Initialize Realm
         
//        fetchMenuCategories(restaurantID: "1")
//        fetchMenuItems()
        
            
//        // Check if restaurant data already exists in Realm
//        let dataExists = realm.objects(Restaurant.self).count > 0
//
//        if !dataExists {
//
//            print("No data exists. Fetching restaurant data.")
//
//            // Retrieving backend number
//            getBackendVersionNumber() {
//                (result: Int) in
//            }
//
//            // Retrieving promotions
//            fetchPromotions() {
//                (result: Int) in
//
//                self.updateIndices()
//                self.myTableView.reloadData()
//            }
//
//            // Show loading view as empty state
//            showDownloadingView()
//
//            // Create models from backend data
////            self.fetchRestaurantData()
//
//        } else {
//
//            print("Data exists. Checking version numbers.")
//
//            let currentVersionNumber = self.defaults.integer(forKey: "currentVersion")
//            getBackendVersionNumber() {
//                (result: Int) in
//
//                print("Received backend version number via closure")
//
//                self.backendVersionNumber = result
//
//                print("Local version number: \(currentVersionNumber), Backend version number: \(self.backendVersionNumber)")
//
//                if currentVersionNumber != self.backendVersionNumber {
//
//                    print("Version numbers do not match. Fetching updated restaurant data.")
//
//                    // Delete current promotions
//                    try! realm.write {
//
//                        let promotions = realm.objects(Promotion.self)
//                        realm.delete(promotions)
//                        print("After deleting, there are \(promotions.count) promotions")
//                    }
//
//                    // Update promotions
//                    self.fetchPromotions() {
//                        (result: Int) in
//
//                        self.updateIndices()
//                        self.myTableView.reloadData()
//                    }
//
//                    // Save new version number to UserDefaults
//                    self.defaults.set(self.backendVersionNumber, forKey: "currentVersion")
//
//                    // Create models from backend data
////                    self.fetchRestaurantData()
//
//                } else {
//
//                    print("Version numbers match. Loading UI.")
//
//                    self.updateIndices()
//                    self.myTableView.reloadData()
//
//                    self.refreshControl.endRefreshing()
//                }
//            }
//        }
    }
    
    // MARK: - Table view data source
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if indexPath.section == 0 {
            return "promotionsCell"
        }
        
        return "restaurantsCell"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var count = 1
        
        if alertMessage != "" {
            count += 1
        }
        
        if promotions.count > 0 {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == promotionsIndex || section == alertMessageIndex {
            return 1
        } else if section == restaurantsIndex {
            return restaurants.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.hideSkeleton()
        
        if indexPath.section == promotionsIndex {
            guard let tableViewCell = cell as? PromotionsTableViewCell else { return }
            
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            if !alreadyDisplayedCollectionView && promotions.count > 2 {
                alreadyDisplayedCollectionView = true
                let i = IndexPath(item: 1, section: 0)
                tableViewCell.myCollectionView.scrollToItem(at: i, at: .centeredHorizontally, animated: true)
            } else {
                tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == promotionsIndex {
            
            guard let tableViewCell = cell as? PromotionsTableViewCell else { return }
            
            storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
        }
    }

    // TODO: ------------- DELETE THIS HARDCODED CRAP ---------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == promotionsIndex {
            return 221
        } else if indexPath.section == restaurantsIndex {
            return UITableView.automaticDimension
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == alertMessageIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "alertMessageCell", for: indexPath)
            
            cell.textLabel?.text = alertMessage
            cell.backgroundColor = alertMessageColor
            
            return cell
        } else if indexPath.section == restaurantsIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantsCell", for: indexPath) as! RestaurantTableViewCell
            
            let restaurant = restaurants[indexPath.row]
            
            cell.name.text = restaurant.name
            if (restaurant.deliveryOnly == 1){
                cell.cuisineType.text = restaurant.cuisineType + " • " + restaurant.restaurantHours.getOpenHoursString()
            } else {
                cell.cuisineType.text = restaurant.cuisineType + " • " + restaurant.pickupHours.getOpenHoursString()
            }
            
//            if let image = restaurant.image {
//                cell.bannerImage.image = UIImage(data: image as Data)
//            }
            
            let image = restaurant.image
            if image != nil {
                
                print("Image is already saved at index: \(indexPath.row).")
                
                cell.bannerImage.image = UIImage(data: image! as Data)
            } else {
                
                let imageURL = restaurant.imageURL
                if imageURL != "" {
                    
                    print("Image is not yet saved. Downloading asynchronously.")
                    
                    DispatchQueue.global(qos: .background).async {
                        let url = URL(string: imageURL)
                        let imageData = NSData(contentsOf: url!)
                        
                        DispatchQueue.main.async {
                            // Cache image
                            let realm = try! Realm() // Initialize Realm
                            try! realm.write {
                                restaurant.image = imageData
                            }
                            
                            // Set image to downloaded asset only if cell is still visible
                            cell.bannerImage.alpha = 0
                            if imageURL == restaurant.imageURL && imageData != nil {
                                cell.bannerImage.image = UIImage(data: imageData! as Data)
                                UIView.animate(withDuration: 0.3) {
                                    cell.bannerImage.alpha = 1
                                }
                            }
                        }
                    }
                } else {
                    print("Image does not exist.")
                    cell.bannerImage.image = nil
                }
            }

            let todaysHours = restaurant.restaurantHours.getOpenHoursString()
            if (restaurant.isOpen()) {
                cell.openHours.text = "Open"
            } else if todaysHours == "Hours unavailable" {
                cell.openHours.text = todaysHours
            } else {
                cell.openHours.text = "Closed"
            }
            
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "promotionsCell", for: indexPath)
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == promotionsIndex {
            // TO-DO: Implement
        } else if indexPath.section == restaurantsIndex {
            if restaurants[indexPath.row] != nil {
                selectedRestaurant = restaurants[indexPath.row]
            }
        }

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == restaurantsIndex {
            return "All Restaurants"
        }
        return ""
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = Constants.darkGray
        header.textLabel?.textAlignment = .left
        if #available(iOS 13.0, *) {
            header.backgroundView?.backgroundColor = UIColor.systemBackground
        } else {
            header.backgroundView?.backgroundColor = UIColor.white
        }
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == restaurantsIndex {
            return Constants.headerHeight
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == alertMessageIndex {
            if let url = NSURL(string:alertMessageLink) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        else if indexPath.section == promotionsIndex {
//            performSegue(withIdentifier: "toPromotionVC", sender: self)
        } else if indexPath.section == restaurantsIndex {
            performSegue(withIdentifier: "toRestaurantDetail", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toRestaurantDetail" {
            let nav = segue.destination as! UINavigationController
            let detailVC = nav.topViewController as! RestaurantDetailViewController
            detailVC.restaurant = selectedRestaurant
        } else if segue.identifier == "toPromotionVC" {
            let promotionVC = segue.destination as! PromotionsViewController
            promotionVC.passedPromotionID = selectedPromotionID
        } else if segue.identifier == "toPastOrdersVC" {
            let pastOrdersVC = segue.destination as! PastOrdersViewController
            pastOrdersVC.restaurants = restaurants
        }
        
    }

}

extension RestaurantsHomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of promotions: \(promotions.count)")
        return promotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "promotionCell", for: indexPath) as! PromotionCollectionViewCell

        let promotion = promotions[indexPath.row]
//        cell.promotionImage.image = UIImage(data: promotions[indexPath.row].image! as Data)
        
        let image = promotion.image
        if image != nil {
            
            print("Image is already saved at index: \(indexPath.row).")
            
            cell.promotionImage.image = UIImage(data: image! as Data)
        } else {
            
            let imageURL = promotion.imageURL
            if imageURL != "" {
                
                print("Image is not yet saved. Downloading asynchronously.")
                
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: imageURL)
                    let imageData = NSData(contentsOf: url!)
                    
                    DispatchQueue.main.async {
                        // Cache image
                        let realm = try! Realm() // Initialize Realm
                        try! realm.write {
                            promotion.image = imageData
                        }
                        
                        // Set image to downloaded asset only if cell is still visible
                        cell.promotionImage.alpha = 0
                        if imageURL == promotion.imageURL && imageData != nil {
                            cell.promotionImage.image = UIImage(data: imageData! as Data)
                            UIView.animate(withDuration: 0.3) {
                                cell.promotionImage.alpha = 1
                            }
                        }
                    }
                }
            } else {
                print("Image does not exist.")
                cell.promotionImage.image = nil
            }
        }
        
        return cell
    }
    
    // TO-DO: Finish implementing this feature
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let restaurantID = promotions[indexPath.row % promotions.count].restaurantID
//        selectedPromotionID = promotions[indexPath.row].id
//        
//        if restaurantID != "0" && restaurantID != nil {
//            
//            selectedRestaurantID = promotions[indexPath.row % promotions.count].restaurantID
//            performSegue(withIdentifier: "toPromotionVC", sender: self)
////            performSegue(withIdentifier: "toRestaurantDetail", sender: self)
//        }
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = UIImage(data: promotions[indexPath.row].image! as Data)?.size.height
//        return CGSize(width: view.frame.width, height: height!)
//    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if promotionsIndex != -1 {
            
            let visibleIndexPaths = myTableView.indexPathsForVisibleRows
            let promotionsIndexPath = IndexPath(row: 0, section: promotionsIndex)
            
            if (visibleIndexPaths?.contains(promotionsIndexPath))! && myTableView.cellForRow(at: promotionsIndexPath) != nil {
                
                print(promotionsIndexPath)
                
                let cell = myTableView.cellForRow(at: promotionsIndexPath) as! PromotionsTableViewCell
                
                if scrollView == cell.myCollectionView {
                    
                    // Find cell closest to the frame centre with reference from the targetContentOffset.
                    let frameCenter: CGPoint = cell.myCollectionView.center
                    var targetOffsetToCenter: CGPoint = CGPoint(x: targetContentOffset.pointee.x + frameCenter.x, y: targetContentOffset.pointee.y + frameCenter.y)
                    var indexPath: IndexPath? = cell.myCollectionView.indexPathForItem(at: targetOffsetToCenter)
                    
                    // Check for "edge case" where the target will land right between cells and then next neighbor to prevent scrolling to index {0,0}.
                    while indexPath == nil {
                        targetOffsetToCenter.x += 10
                        indexPath = cell.myCollectionView.indexPathForItem(at: targetOffsetToCenter)
                    }
                    // safe unwrap to make sure we found a valid index path
                    if let index = indexPath {
                        // Find the centre of the target cell
                        if let centerCellPoint: CGPoint = cell.myCollectionView.layoutAttributesForItem(at: index)?.center {
                            
                            // Calculate the desired scrollview offset with reference to desired target cell centre.
                            let desiredOffset: CGPoint = CGPoint(x: centerCellPoint.x - frameCenter.x, y: centerCellPoint.y - frameCenter.y)
                            targetContentOffset.pointee = desiredOffset
                        }
                    }
                }
                
            }

        }
            
            
            
    }
            

}
