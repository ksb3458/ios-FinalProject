import UIKit

class ViewController: UIViewController, UIScrollViewDelegate{
   
    var movieList: [[String]] = []
    var hotMovieList: [[String]] = []
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hotScrollView: UIScrollView!
    @IBOutlet weak var dropButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.getHotMovieList()
        self.addTopContentScrollView()
        self.setPageControl()
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.systemGray5
        setupPopUpButton()
        
        scrollView.delegate = self
        hotScrollView.delegate = self
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
            self.addTopContentScrollView()
        }
        
        let sortScore = { [self] (action: UIAction) in
            movieList = movieList.sorted(by: {$0[20] > $1[20] })
            self.addTopContentScrollView()
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
        //movieListInitSet()
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
    
    private func addTopContentScrollView() {
        for  subview in self.scrollView.subviews
        {
            subview.removeFromSuperview()
        }
        
        for i in 0 ... 4 {
            for j in 0 ... 5 {
                let imageView = UIImageView()
                let xPos = scrollView.frame.width * CGFloat(i)
                let yPos = scrollView.bounds.height / 5 * CGFloat(j)
                imageView.frame = CGRect(x: xPos, y: yPos, width: scrollView.bounds.width / 6.8, height: scrollView.bounds.height / 5.4)
                imageView.image = image
                let label = UILabel()
                label.frame = CGRect(x: xPos + scrollView.bounds.width / 4.85, y: yPos - 17, width: 260, height: scrollView.bounds.height / 5)
                label.text = String(i*5 + j + 1)+"  "+movieList[i*5 + j][1]
                label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                label.textColor = UIColor.white
                label.lineBreakMode = .byTruncatingTail
                
                imageView.tag = i*5 + j
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewTopTapped)))
                label.tag = i*5 + j
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewTopTapped)))
                
                scrollView.addSubview(imageView)
                scrollView.addSubview(label)
                scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1) * 5.43
            }
        }
    }
    
    @objc func viewTopTapped(_ sender: UITapGestureRecognizer) {
        let index = sender.view?.tag
        goToDetailViewController(controller: "DetailViewController", title: movieList[index!][1])
    }
    
    private func getHotMovieList() {
        movieList = movieList.sorted(by: {$0[13] > $1[13] })
        for i in 0...20 {
            hotMovieList.append(movieList[i])
        }
        movieListInitSet()
        addHotContentScrollView()
    }
    
    
    private func addHotContentScrollView() {
        for  subview in self.hotScrollView.subviews
        {
            subview.removeFromSuperview()
        }
        
        for i in 0 ..< 20 {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: CGFloat(i) * 115, y: 0, width: hotScrollView.bounds.width / 3.5, height: hotScrollView.bounds.height / 8 * 6.8)
            imageView.image = image
            let label = UILabel()
            label.frame = CGRect(x: CGFloat(i) * 115, y: 132, width: imageView.bounds.width - 10, height: hotScrollView.bounds.height / 3.5)
            label.text = hotMovieList[i][1]
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = UIColor.white
            
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewHotTapped)))
            label.tag = i
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewHotTapped)))
            
            hotScrollView.addSubview(imageView)
            hotScrollView.addSubview(label)
            hotScrollView.contentSize.width = imageView.frame.width * CGFloat(i) * 1.16
        }
    }
    
    @objc func viewHotTapped(_ sender: UITapGestureRecognizer) {
        let index = sender.view?.tag
        goToDetailViewController(controller: "DetailViewController", title: hotMovieList[index!][1])
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
    
    @IBAction func top20Btn(_ sender: Any) {
        goToViewController(controller: "TopViewController")
    }
    @IBAction func animationBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Animation")
    }
    @IBAction func actionBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Action")
    }
    @IBAction func adventureBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Adventure")
    }
    @IBAction func thrillerBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Thriller")
    }
    @IBAction func fantasyBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Fantasy")
    }
    @IBAction func familyBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Family")
    }
    @IBAction func dramaBtn(_ sender: Any) {
        goToSortViewController(controller: "SortViewController", id: "Drama")
    }
    @IBAction func hotBtn(_ sender: Any) {
        goToViewController(controller: "HotViewController")
    }
    
    func goToViewController(controller: String) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: controller)
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func goToDetailViewController(controller: String, title: String) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
        as? DetailViewController else {return}
        viewController.movieName = title
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToSortViewController(controller: String, id: String) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SortViewController")
        as? SortViewController else {return}
        viewController.viewTitle = id
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
