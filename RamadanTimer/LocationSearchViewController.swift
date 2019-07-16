//
//  LocationSearchViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 24/06/18.
//  Copyright © 2018 Sumayyah. All rights reserved.
//

import UIKit

class LocationSearchViewController: UITableViewController, UISearchBarDelegate {
    
    /// all cities
    var cities: [City] = []
    /// filtered cities after search
    var filteredCities: [City] = []
    
    /// should filter according to search
    var shouldShowSearchResults = false
    
    /// selected city
    var selectedCity: City!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        cities = delegate.getCities() as! [City]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowSearchResults ? filteredCities.count : cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)

        // Configure the cell...
        let requiredCities = shouldShowSearchResults ? filteredCities : cities
        
        let name = requiredCities[indexPath.row].name ?? ""
        let country = requiredCities[indexPath.row].country ?? ""
        cell.textLabel?.text = "\(name), \(country)"

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let requiredCities = shouldShowSearchResults ? filteredCities : cities
        selectedCity = requiredCities[indexPath.row]
        performSegue(withIdentifier: "locationDetailSegue", sender: nil)
    }
    
    // MARK: - Search
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter array
        filteredCities = cities.filter({ (city) -> Bool in
            return city.name!.range(of: searchText, options: .caseInsensitive) != nil || city.country!.range(of: searchText, options: .caseInsensitive) != nil
        })
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected city to the new view controller.
        if let locationDetail = segue.destination as? LocationDetailViewController {
            locationDetail.location = selectedCity
        }
    }
    

}
