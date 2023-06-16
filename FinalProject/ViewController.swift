import UIKit

class ViewController: UIViewController, UIScrollViewDelegate{
   
    var movieList: [[String]] = []
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    var imageViews = [UIImageView]()
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dropButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.addContentScrollView()
        self.setPageControl()
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        setupPopUpButton()
        
        scrollView.delegate = self
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
            self.addContentScrollView()
        }
        
        let sortScore = { [self] (action: UIAction) in
            movieList = movieList.sorted(by: {$0[20] > $1[20] })
            self.addContentScrollView()
        }

        dropButton.menu = UIMenu(children: [
            UIAction(title: "평가개수", handler: sortNum),
            UIAction(title: "평균평점", handler: sortScore)
        ])
        dropButton.showsMenuAsPrimaryAction = true
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
        //self.tableView.reloadData()
    }
    
    private func addContentScrollView() {
        for  subview in self.scrollView.subviews
        {
            subview.removeFromSuperview()
        }
        
        for i in 0 ... 4 {
            for j in 0 ... 5 {
                let imageView = UIImageView()
                let xPos = scrollView.frame.width * CGFloat(i)
                let yPos = scrollView.bounds.height / 5 * CGFloat(j)
                imageView.frame = CGRect(x: xPos, y: yPos, width: scrollView.bounds.width / 4, height: scrollView.bounds.height / 5)
                imageView.image = image
                let label = UILabel()
                label.frame = CGRect(x: xPos + scrollView.bounds.width / 4, y: yPos, width: scrollView.bounds.width, height: scrollView.bounds.height / 5)
                label.text = String(i*5 + j + 1)+". "+movieList[i*5 + j][1]
                
                scrollView.addSubview(imageView)
                scrollView.addSubview(label)
                scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1) * 3.2
            }
        }
    }
    
    private func setPageControl() {
        pageControl.numberOfPages = 4
    }
    
    private func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SortViewController {
            viewController.viewTitle = segue.identifier!
        }
    }
}

