//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate, UINavigationBarDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses : [Business]!
    var loadingData = false
    var loadingMoreView:InfiniteScrollActivityView?
    var initialDistance = 1000.0
    @IBOutlet weak var tableView: UITableView!
    let searchBar = UISearchBar()
    var infiniteScrollFilters = [String : AnyObject]()
    var filtersViewControllerInfiniteScroll: FiltersViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Restaurants"
        self.navigationItem.titleView = searchBar
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        UINavigationBar.appearance().barTintColor = UIColor.red
        navigationController?.navigationBar.barTintColor = UIColor.red
        //UIBarButtonItem.appearance().tintColor = UIColor.white
        //Since iOS 7.0 UITextAttributeTextColor was replaced by NSForegroundColorAttributeName
       // UINavigationBar.appearance().titleTextAttributes = [UIColor.white]
        Business.searchWithTerm(term: "Restuarants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businessCount = businesses {
            return businessCount.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func FiltersViewController(FiltersViewController: FiltersViewController, Filters: [String : AnyObject]) {
        self.infiniteScrollFilters = Filters
        var categories : [String]?
        if (Filters["categories"] != nil && (Filters["categories"] as! [String]).count > 0){
            categories = Filters["categories"] as! [String]
        } else {
            categories = nil
        }
        var dealOffer = false
        if ((Filters["DealOffers"]?[0]) != nil){
            dealOffer = true
        }
        var radius:Double?
        if (Filters["Distance"]?[0] != nil){
           radius = Filters["Distance"]?[0] as! Double
        } else {
            radius = nil
        }
        var sortBy:Int?
        if (Filters["Sort By"]?[0] != nil){
            sortBy = Filters["Sort By"]?[0] as! Int
        } else {
            sortBy = 0
        }
//        print(Filters["categories"]?[0])
//        print(Filters["Sort By"]?[0])
//        print(Filters["Distance"]?[0])
//        print(Filters["DealOffers"]?[0])
        Business.searchWithTerm(term: "Restaurants", sort: YelpSortMode(rawValue:sortBy!), categories: categories, distance: radius, deals: dealOffer){ (businesses: [Business]!, NSError) -> Void in
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.tableView.reloadData()}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.filtersDelegate = self
        self.filtersViewControllerInfiniteScroll = filtersViewController
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchPredicate1 = NSPredicate(format: "categories CONTAINS[C] %@", searchText)
        let searchPredicate2 = NSPredicate(format: "name CONTAINS[C] %@", searchText)
        let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [searchPredicate1,searchPredicate2])
        self.businesses = self.businesses?.filter { predicateCompound.evaluate(with: $0) };
        if searchText == "" {
            self.businesses = self.filteredBusinesses
        }
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.businesses = self.filteredBusinesses
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!loadingData){
            let scrollViewContentHeight = tableView.contentSize.height
//            print("tableviewcontentsize \(tableView.contentSize.height)")
//            print("tableVieHeight \(tableView.bounds.size.height)")
//            print("scrollOffset \(scrollView.contentOffset.y)")
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                loadingData = true
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                if (self.infiniteScrollFilters.values.count > 0){
                    var distanceArr = [Double]()
                    if (self.infiniteScrollFilters["Distance"]?[0] != nil){
                        let distanceFetch = self.infiniteScrollFilters["Distance"]?[0] as! Double + 5000.0
                        distanceArr.append(distanceFetch)
                        self.infiniteScrollFilters["Distance"] = distanceArr as AnyObject
                    } else {
                        distanceArr.append(5000.0)
                        self.infiniteScrollFilters["Distance"] = distanceArr as AnyObject
                    }
                 //  print("************")
                   FiltersViewController(FiltersViewController: self.filtersViewControllerInfiniteScroll!, Filters: self.infiniteScrollFilters)
                    self.loadingMoreView!.stopAnimating()
                } else {
                //print("+++++++++++++")
                self.initialDistance = self.initialDistance + 5000
                Business.searchWithTerm(term: "Restuarants",distance: self.initialDistance, completion: { (businesses: [Business]?, error: Error?) -> Void in
                    
                    self.businesses = businesses
                    self.filteredBusinesses = businesses
                    self.tableView.reloadData()
                    self.loadingData = false
                    self.loadingMoreView!.stopAnimating()
                    })
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
