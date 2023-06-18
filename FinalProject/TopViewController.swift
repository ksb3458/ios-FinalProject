import UIKit

class TopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var movieList: [[String]] = []
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    let bgColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.setupPopUpButton()
        self.setTitle()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
    }
    
    func setTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "TOP20"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "")
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
        }
        movieList.remove(at: 100)
        movieListInitSet()
    }
    
    private func movieListInitSet() {
        movieList = movieList.sorted(by: {$0[21] > $1[21] })
        var chk = 0
        for i in 0 ..< movieList.count {
            if movieList[i][21].count == 6 {
                movieList.insert(movieList[i], at: chk)
                movieList.remove(at: i + 1)
                chk += 1
            }
        }
    }
    
    func setupPopUpButton() {
        let sortNum = { [self] (action: UIAction) in
            movieList = movieList.sorted(by: {$0[21] > $1[21] })
            var chk = 0
            for i in 0 ..< movieList.count {
                if movieList[i][21].count == 6 {
                    movieList.insert(movieList[i], at: chk)
                    movieList.remove(at: i + 1)
                    chk += 1
                }
            }
            tableView.reloadData()
        }
        
        let sortScore = { [self] (action: UIAction) in
            movieList = movieList.sorted(by: {$0[20] > $1[20] })
            tableView.reloadData()
        }

        dropButton.menu = UIMenu(children: [
            UIAction(title: "평가개수", handler: sortNum),
            UIAction(title: "평균평점", handler: sortScore)
        ])
        dropButton.showsMenuAsPrimaryAction = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopTableViewCell") as! TopTableViewCell
        cell.backgroundColor = bgColor
        cell.poster?.image = image
        cell.number?.text = String(indexPath.row + 1)
        cell.title?.text = movieList[indexPath.row][1]

        let time = Int(movieList[indexPath.row][15])
        let timeData = "\(time!/60)H \(time!%60)M"
        cell.info?.text = "\(movieList[indexPath.row][13]), \(timeData)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController {
            if let selectdeIndex =
                self.tableView.indexPathForSelectedRow?.row {
                    viewController.movieName = movieList[selectdeIndex][1]
            }
        }
    }
}
