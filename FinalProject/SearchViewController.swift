import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var movieList: [[String]] = []
    var searchName = 0 //0:영화 1:배우
    var searchField = [Int]()
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    var starImageViews: [UIImageView] = []
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.setupPopUpButton()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
    }
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata3", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
    }
    
    private func parseCSVAt(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: "##,")}) {
                for item in dataArr {
                    movieList.append(item)
                }
            }
        } catch {
            print("Error reading CSV file")
        }
        
        for i in 0..<movieList.count - 1{
            for j in 0..<17 {
                if(j == 3 || j == 9 || j == 11 || j == 16) {
                    let data = String(movieList[i][j])
                    let dataArr = data.components(separatedBy: "##\",")
                    movieList[i].remove(at: j)
                    for item in dataArr.reversed() {
                        movieList[i].insert(item, at: j)
                    }
                }
            }
            //print("\(String(i)) : \(String(movieList[i].count))")
        }
        movieList.remove(at: 100)
        movieList = movieList.sorted(by: {$0[20] > $1[20] })
    }

    private func makeAlert()
    {
        let alert = UIAlertController(title:"검색어를 입력해주세요!",message: "",preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func searchBtn(_ sender: UIButton) {
        searchField.removeAll()
        
        if searchName == 0 {
            if(textField.text == " " || (textField.text?.count) == 0) { makeAlert() }
            else {
                let tfText: String? = textField.text
                for i in 0 ..< movieList.count {
                    if let text = tfText {
                        if movieList[i][1].lowercased().contains(text.lowercased()) {
                            searchField.append(i)
                        }
                    }
                }
                tableView.reloadData()
            }
        }
        
        if searchName == 1 {
            if((textField.text?.isEmpty) == nil) { makeAlert() }
            else {
                let tfText: String? = textField.text
                for i in 0 ..< movieList.count {
                    if let text = tfText {
                        if movieList[i][1].contains(text) {
                            print(text)
                            print(movieList[i][1])
                            searchField.append(i)
                        }
                    }
                }
                tableView.reloadData()
            }
        }
    }
    
    func setupPopUpButton() {
        let movieName = { [self] (action: UIAction) in
            searchName = 0
        }
        
        let actorName = { [self] (action: UIAction) in
            searchName = 1
        }

        dropButton.menu = UIMenu(children: [
            UIAction(title: "영화명", handler: movieName),
            UIAction(title: "배우명", handler: actorName)
        ])
        dropButton.showsMenuAsPrimaryAction = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchField.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        
        cell.Poster?.image = image
        cell.Name?.text = movieList[searchField[indexPath.row]][1]
        var firstOverview = movieList[searchField[indexPath.row]][9].components(separatedBy: ".")
        firstOverview[0] = String(firstOverview[0].dropFirst(1))
        cell.Overview?.text = firstOverview[0]
        cell.Id?.text = "#" + movieList[searchField[indexPath.row]][5]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController {
            if let selectdeIndex =
                self.tableView.indexPathForSelectedRow?.row {
                    viewController.movieName = movieList[searchField[selectdeIndex]][1]
            }
        }
    }
}
