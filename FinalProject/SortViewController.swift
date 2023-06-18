import UIKit

class SortViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var viewTitle : String = ""
    var movieList: [[String]] = []
    var collectionList: [[String]] = []
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dropButton: UIButton! 
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.setupPopUpButton()
        self.setTitle()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setTitle() {
        let titleLabel = UILabel()
        titleLabel.text = viewTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "")
        
        getCollectionData()
        collectionView.reloadData()
    }
    
    func setupPopUpButton() {
        let sortNum = { [self] (action: UIAction) in
            collectionList = collectionList.sorted(by: {$0[21] > $1[21] })
            var chk = 0
            for i in 0 ..< collectionList.count {
                if collectionList[i][21].count == 6 {
                    collectionList.insert(movieList[i], at: chk)
                    collectionList.remove(at: i + 1)
                    chk += 1
                }
            }
            collectionView.reloadData()
        }
        
        let sortScore = { [self] (action: UIAction) in
            collectionList = collectionList.sorted(by: {$0[20] > $1[20] })
            collectionView.reloadData()
        }

        dropButton.menu = UIMenu(children: [
            UIAction(title: "평가개수", handler: sortNum),
            UIAction(title: "평균평점", handler: sortScore)
        ])
        dropButton.showsMenuAsPrimaryAction = true
    }
    
    func getCollectionData() {
        for i in 0..<movieList.count {
            if((movieList[i][3].lowercased()).contains(viewTitle.lowercased())) {
                collectionList.append(movieList[i])
            }
        }
        setCountLabel()
    }
    
    func setCountLabel() {
        let green = UIColor(red: 85/255, green: 189/255, blue: 103/255, alpha: 1.0)
        let originalString = "총 \(collectionList.count)개 작품"
        let attributedText = NSMutableAttributedString(string: originalString)
        let range = (originalString as NSString).range(of: "\(collectionList.count)")
        attributedText.addAttribute(.foregroundColor, value: green, range: range)
        countLabel.attributedText = attributedText
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
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata3", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectCell", for: indexPath) as? SortCollectionViewCell else {
                return UICollectionViewCell()
        }
        cell.imageView?.image = image
        cell.label?.text = collectionList[indexPath.row][1]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController {
            if let selectdeIndex =
                self.collectionView.indexPathsForSelectedItems?.last {
                    viewController.movieName = collectionList[selectdeIndex.item][1]
            }
        }
    }
}
