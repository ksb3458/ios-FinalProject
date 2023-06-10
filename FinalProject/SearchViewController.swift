import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var movieList: [[String]] = []
    
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.setupPopUpButton()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func parseCSVAt(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: "\"[")}) {
                for item in dataArr {
                    movieList.append(item)
                }
            }
        } catch {
            print("Error reading CSV file")
        }
        
        for i in 0..<movieList.count - 1 {
            for j in 0..<10 {
                if(j == 1 || j==5 || j==7 || j==9) {
                    let data = String(movieList[i][j])
                    let dataArr = data.components(separatedBy: "]\"")
                    movieList[i].remove(at: j)
                    for item in dataArr.reversed() {
                        movieList[i].insert(item, at: j)
                    }
                }
                if(j == 2) {
                    let data = String(movieList[i][j])
                    let dataArr = data.components(separatedBy: "\"")
                    movieList[i].remove(at: j)
                    for item in dataArr.reversed() {
                        movieList[i].insert(item, at: j)
                    }
                }
            }
            
            for j in 0..<23 {
                if(j == 0 || j == 4 || j == 10 || j == 16 || j == 22) {
                    let data = String(movieList[i][j])
                    let dataArr = data.components(separatedBy: ",")
                    movieList[i].remove(at: j)
                    for item in dataArr.reversed() {
                        movieList[i].insert(item, at: j)
                    }
                }
            }
            
            movieList[i].remove(at: 2)
            movieList[i].remove(at: 3)
            movieList[i].remove(at: 6)
            movieList[i].remove(at: 7)
            movieList[i].remove(at: 8)
            movieList[i].remove(at: 9)
            movieList[i].remove(at: 10)
            movieList[i].remove(at: 13)
            movieList[i].remove(at: 14)
        }
        movieList.remove(at: 100)
    }
    
    
    @IBAction func searchBtn(_ sender: UIButton) {
        print("btn")
    }
    
    func setupPopUpButton() {
        let movieName = { (action: UIAction) in
            print("movie")
        }
        
        let actorName = { (action: UIAction) in
            print("actor")
        }

        dropButton.menu = UIMenu(children: [
            UIAction(title: "영화명", handler: movieName),
            UIAction(title: "배우명", handler: actorName)
        ])
        dropButton.showsMenuAsPrimaryAction = true
    }
    
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
        //self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        cell.textLabel?.text = movieList[indexPath.row][0]
        cell.detailTextLabel?.text = movieList[indexPath.row][1]
        return cell
    }
}
