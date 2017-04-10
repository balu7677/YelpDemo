//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Tummala, Balaji on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    func FiltersViewController(FiltersViewController: FiltersViewController, Filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var categories = [[String:String]]()
    var hidden:[Bool] = [true, true, true, true]
    var selectedCategories = [IndexPath : Bool]()
    var sections = ["DealOffers","Distance","Sort By","Category"]
    var filtersDelegate: FiltersViewControllerDelegate?
    var distance = ["0.3","1","5","20"]
    var sortBy = ["Best Match", "Distance", "Highest Rated"]
    var dealOffers = ["Offering a Deal"]
    var mainDict = [String : [AnyObject]]()
    var sectionsDict = ["DealOffers","Distance","Sort By","Category"]
    var distanceDict = ["0.3":500,"1":1700,"5":8000,"20":32000]
    var sortByDict = ["Best Match": 0, "Distance":1, "Highest Rated":2]
    var dealOffersDict = ["Offering a Deal":true]
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: tableView.frame.width, height: 20))
        label.textAlignment = .left
        label.font = UIFont(name:"Helvetica-Semibold", size: 18.0)
        label.textColor = UIColor.white
        view.backgroundColor = UIColor.red
        label.text = sections[section] + "  -> Click to expand/collapse"
        label.tag = section
        view.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return view
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        let section = sender.view!.tag
        let sectionName = sections[section]
        let count = mainDict[sectionName]?.count
        let indexPaths = (0..<count!).map { i in return IndexPath(item: i, section: section)  }
        
        hidden[section] = !hidden[section]
        
        tableView?.beginUpdates()
        if hidden[section] {
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView?.insertRows(at: indexPaths, with: .fade)
        }
        tableView?.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = yelpCategories()
        mainDict["DealOffers"] = dealOffers as [AnyObject]
        mainDict["Distance"] = distance as [AnyObject]
        mainDict["Sort By"] = sortBy as [AnyObject]
        mainDict["Category"] = categories as [AnyObject]
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle = sections[section]
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sections[section]
        if hidden[section] {
            return 0
        } else {
            return (mainDict[sectionName]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        let selectedSection = sections[indexPath.section]
        if selectedSection == "Category" {
            cell.filterLabel.text = categories[indexPath.row]["name"]
        } else {
            cell.filterLabel.text = mainDict[selectedSection]?[indexPath.row] as! String
        }
        
        
        cell.delegate = self
        cell.onSwitch.isOn = selectedCategories[indexPath] ?? false
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func SwitchCell(SwitchCell: SwitchCell, cellSelected: Bool) {
        let indexPath = tableView.indexPath(for: SwitchCell)
    //    innerDict[(sections.count * (indexPath?.section)!) + (indexPath?.row)!] = cellSelected
        selectedCategories[indexPath!] = cellSelected
        if sections[(indexPath?.section)!] == "Distance" {
            let sectionNumber = indexPath?.section
            let indexSet: IndexSet = [sectionNumber!]
            for index in 0...3 {
                if(index != indexPath?.row){
                    let iPath = NSIndexPath(row: index, section: sectionNumber!)
                    selectedCategories[iPath as IndexPath] = false
                }
            }
            tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
        } else if sections[(indexPath?.section)!] == "Sort By"{
            let sectionNumber = indexPath?.section
            let indexSet: IndexSet = [sectionNumber!]
            for index in 0...2 {
                if(index != indexPath?.row){
                    let iPath = NSIndexPath(row: index, section: sectionNumber!)
                    selectedCategories[iPath as IndexPath] = false
                }
            }
            tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
        }
            
       // selectedCategories[(indexPath?.section)!] = innerDict
        //print(selectedCategories[(indexPath?.section)!]?[(indexPath?.row)!])
//
//        for (k,v) in selectedCategories {
//            if(v) {
//                    print("Section: \(k.section) and row: \(k.row)")
//                }
//            }
//        print("************")
//
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearch(_ sender: Any) {
        var filters = [String:AnyObject]()
        var categoriesSelected = [String]()
        var sortBySelected = [Int]()
        var distanceSelected = [Double]()
        var dealSelected = [Bool]()
        for (key,isSelected) in selectedCategories {
            if (isSelected && (sections[key.section] == "Category")) {                    categoriesSelected.append(mainDict[sections[key.section]]![key.row]["code"]! as! String)
            } else if (isSelected && (sections[key.section] == "Sort By")){
                    sortBySelected.append(sortByDict[mainDict[sections[key.section]]?[key.row] as! String]!)
            } else if (isSelected && (sections[key.section] == "Distance")){
                    distanceSelected.append(Double(distanceDict[mainDict[sections[key.section]]?[key.row] as! String]!))
            } else if (isSelected && (sections[key.section] == "DealOffers")){
                    dealSelected=([dealOffersDict[mainDict[sections[key.section]]?[key.row] as! String]!])
            }
        }
        if categoriesSelected.count > 0{
            filters["categories"] = categoriesSelected as AnyObject
        }
        if sortBySelected.count > 0{
            filters["Sort By"] = sortBySelected as AnyObject
        }
        if distanceSelected.count > 0{
            filters["Distance"] = distanceSelected as AnyObject
        }
        if dealSelected.count > 0{
            filters["DealOffers"] = dealSelected as AnyObject
        }
        
        filtersDelegate?.FiltersViewController(FiltersViewController: self, Filters: filters)
        dismiss(animated: true, completion: nil)
    }
    
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }
    
   // func distanceCategories() -> [[String:]]
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
