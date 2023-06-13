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
        self.setStackView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
    }
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
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
        movieList = movieList.sorted(by: {$0[17] > $1[17] })
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
                        if movieList[i][0].lowercased().contains(text.lowercased()) {
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
                        if movieList[i][0].contains(text) {
                            print(text)
                            print(movieList[i][0])
                            searchField.append(i)
                        }
                    }
                }
                tableView.reloadData()
            }
        }
    }
    
    func setStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        setRatingImageView()
    }

    // 반복문을 이용하여 Stack View에 별 Image View 추가
    func setRatingImageView() {
        for i in 0..<5 {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "star_empty")
            imageView.tag = i
            let xPos = stackView.frame.width / 5 * CGFloat(i)
            let yPos = 0 * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: yPos, width: (imageView.image?.size.width)! / 10, height: (imageView.image?.size.height)! / 10)
            stackView.addSubview(imageView)
            starImageViews.append(stackView.subviews[i] as? UIImageView ?? UIImageView())
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
        cell.Name?.text = movieList[searchField[indexPath.row]][0]
        let firstOverview = movieList[searchField[indexPath.row]][6].components(separatedBy: ".")
        cell.Overview?.text = firstOverview[0]
        cell.Id?.text = "#" + movieList[searchField[indexPath.row]][3]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //클릭한 셀의 이벤트 처리
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController {
            if let selectdeIndex =
                self.tableView.indexPathForSelectedRow?.row {
                    viewController.name = movieList[searchField[selectdeIndex]][0]
            }
        }
    }
}
