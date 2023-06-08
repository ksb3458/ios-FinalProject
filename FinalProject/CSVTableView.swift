//
//  CSVTableView.swift
//  FinalProject
//
//  Created by 컴퓨터공학부 on 2023/06/08.
//

import UIKit

class CSVTableView: UITableView {
    var cityAndCountry:[[String]] = []
    
    private func loadLocationsFromCSV() {
            let path = Bundle.main.path(forResource: "movies_metadata", ofType: "csv")!
            parseCSVAt(url: URL(fileURLWithPath: path))
            tableView.reloadData()
    }
        
    private func parseCSVAt(url:URL) {
        do {
                
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
                
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                for item in dataArr {
                    cityAndCountry.append(item)
                }
            }
        } catch  {
            print("Error reading CSV file")
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        return cityAndCountry.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CSVTableViewCell") as! CSVTableViewCell
        cell.textLabel?.text = cityAndCountry[indexPath.row][0]
        cell.detailTextLabel?.text = cityAndCountry[indexPath.row][1]
        return cell
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
