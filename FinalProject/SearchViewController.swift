import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate  {

    var movieList: [[String]] = []
    var actorList: [[String]] = []
    var crewList: [[String]] = []
    var searchList: [String] = []
    var searchName = 0 //0:영화 1:배우
    var searchField = [Int]()
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    var starImageViews: [UIImageView] = []
    var inputText: String = ""
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.loadCrewFromCSV()
        self.setupPopUpButton()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
        textField.delegate = self
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        //view.addGestureRecognizer(tapGesture)
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
        //movieList = movieList.sorted(by: {$0[20] > $1[20] })
    }
    
    private func loadActorFromCSV() {
        let path = Bundle.main.path(forResource: "actor_metadata", ofType: "csv")!
        parseActorCSVAt(url: URL(fileURLWithPath: path))
    }
    
    private func parseActorCSVAt(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\"[").map({$0.components(separatedBy: ",")}) {
                for item in dataArr {
                    actorList.append(item)
                }
            }
        } catch {
            print("Error reading CSV file")
        }
        
        actorList.remove(at: 0)
        for i in 0..<actorList.count {
            for j in stride(from: 5, to: actorList[i].count, by: 8) {
                var str : [String]
                str = actorList[i][j].components(separatedBy: ": ")
                movieList[i].append(str[1])
            }
        }
        movieList = movieList.sorted(by: {$0[20] > $1[20] })
    }
    
    private func loadCrewFromCSV() {
        let path = Bundle.main.path(forResource: "crewData", ofType: "csv")!
        parseCrewCSVAt(url: URL(fileURLWithPath: path))
    }
    
    private func parseCrewCSVAt(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\"[").map({$0.components(separatedBy: ",")}) {
                for item in dataArr {
                    crewList.append(item)
                }
            }
        } catch {
            print("Error reading CSV file")
        }
        
        crewList.remove(at: 0)
        for i in 0..<crewList.count {
            for j in stride(from: 4, to: crewList[i].count, by: 7) {
                var str : [String]
                str = crewList[i][j].components(separatedBy: ": ")
                if str[1] == "'Director'" {
                    var str : [String]
                    str = crewList[i][j+1].components(separatedBy: ": ")
                    movieList[i].append(str[1])
                    break
                }
            }
        }
        loadActorFromCSV()
    }

    private func makeAlert()
    {
        let alert = UIAlertController(title:"검색어를 입력해주세요!",message: "",preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func searchBtn(_ sender: UIButton) {
        if(textField.text == " " || (textField.text?.count) == 0) { makeAlert() }
        else {
            search()
        }
    }
    
    func search() {
        searchField.removeAll()
        if searchName == 0 {
            let tfText: String? = inputText
            for i in 0 ..< movieList.count {
                if let text = tfText {
                    if movieList[i][1].lowercased().contains(text.lowercased()) {
                        searchField.append(i)
                    }
                }
            }
            tableView.reloadData()
        }
        
        if searchName == 1 {
            let tfText: String? = inputText
            for i in 0 ..< movieList.count {
                if let text = tfText {
                    for j in 23 ..< movieList[i].count {
                        if movieList[i][j].lowercased().contains(text.lowercased()) {
                            searchField.append(i)
                            break
                        }
                    }
                }
            }
            tableView.reloadData()
        }
        
        if searchName == 2 {
            let tfText: String? = inputText
            for i in 0 ..< movieList.count {
                if let text = tfText {
                    if movieList[i][22].lowercased().contains(text.lowercased()) {
                        searchField.append(i)
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    func setupPopUpButton() {
        let movieName = { [self] (action: UIAction) in
            searchName = 0
        }
        
        let actorName = { [self] (action: UIAction) in
            searchName = 1
        }
        
        let directorName = { [self] (action: UIAction) in
            searchName = 2
        }

        dropButton.menu = UIMenu(children: [
            UIAction(title: "영화명", handler: movieName),
            UIAction(title: "배우명", handler: actorName),
            UIAction(title: "감독명", handler: directorName)
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
    
    //@objc func handleTap(sender: UITapGestureRecognizer) {
    //    if sender.view != textField {
    //        textField.resignFirstResponder()
    //    } else {
    //        textField.becomeFirstResponder()
    //    }
    //}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        inputText = currentText
        search()
        return true
    }
}
