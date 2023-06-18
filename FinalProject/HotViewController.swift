import UIKit

class HotViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var viewTitle : String = ""
    var movieList: [[String]] = []
    var collectionList: [[String]] = []
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.getCollectionData()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //navigationItem.title = "HOT & NEW"
        let titleLabel = UILabel()
        titleLabel.text = "HOT & NEW"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "")
    }
    
    func getCollectionData() {
        for i in 0..<20 {
            collectionList.append(movieList[i])
        }
        collectionView.reloadData()
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
        movieList = movieList.sorted(by: {$0[13] > $1[13] })
    }
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata3", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HotCell", for: indexPath) as? HotCollectionViewCell else {
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
