import UIKit

class DetailViewController: UIViewController {

    var movieName : String?
    var movieStar : Float?
    var starImageViews : [UIImageView] = []
    var movieList: [[String]] = []
    var starList: [[String]] = []
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.loadStarDataFromCSV()
        self.setStackView()
        self.setSlider()
        self.findMovieData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.saveStarData()
    }
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv")!
        parseMovieDataAt(url: URL(fileURLWithPath: path))
    }
    
    private func parseMovieDataAt(url: URL) {
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
    
    private func loadStarDataFromCSV() {
        let path = Bundle.main.path(forResource: "starData", ofType: "csv")!
        parseStarDataAt(url: URL(fileURLWithPath: path))
    }
    
    private func parseStarDataAt(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                for item in dataArr {
                    starList.append(item)
                }
            }
        } catch {
            print("Error reading CSV file")
        }
        starList.remove(at: 100)
        print(starList)
    }
    
    func findMovieData() { //정보 가져오기
        for i in 0 ..< movieList.count {
            if(movieList[i][0] == movieName) {
                //label 바꾸고 .. 등등
                print(movieList[i][0])
                break
            }
            if(i==movieList.count - 1) {
                print("error - no name")
            }
        }
        
        for i in 0 ..< starList.count {
            if(starList[i][0] == movieName) {
                print(starList[i][1])
                slider.value = Float(starList[i][1])!
                var value = slider.value
                for i in 0..<5 {
                    if value > 0.5 {
                        value -= 1
                        starImageViews[i].image = UIImage(named: "star_full")
                    }
                    else if 0 < value && value < 0.5 {
                        value -= 0.5
                        starImageViews[i].image = UIImage(named: "star_half")
                    }
                    else {
                        starImageViews[i].image = UIImage(named: "star_empty")
                    }
                }
                break
            }
            if(i==starList.count - 1) {
                print("error - no star data")
            }
        }
    }
    
    func saveStarData() {
        var newData : String?
        for i in 0 ..< starList.count {
            if(starList[i][0] == movieName) {
                starList[i][1] = String(slider.value)
            }
            newData?.append("\(starList[i][0]),\(starList[i][1])")
        }
        
        do {
            let path = Bundle.main.path(forResource: "starData", ofType: "csv")!
            try newData?.write(to: URL(fileURLWithPath: path), atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let dataEncoded = String(data: data, encoding: .utf8)
            print(dataEncoded as Any)
        } catch(_) {
            print("error")
        }
    }
    
    func setStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        setRatingImageView()
    }

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
    
    func setSlider() {
        slider.maximumValue = 5
        slider.minimumValue = 0
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .clear
        slider.thumbTintColor = .clear
        slider.addTarget(self, action: #selector(tapSlider(_:)), for: .valueChanged)
    }
    
    @objc func tapSlider(_ sender: UISlider) {
        var value = sender.value
        
        for i in 0..<5 {
            if value > 0.5 {
                value -= 1
                starImageViews[i].image = UIImage(named: "star_full")
            }
            else if 0 < value && value < 0.5 {
                value -= 0.5
                starImageViews[i].image = UIImage(named: "star_half")
            }
            else {
                starImageViews[i].image = UIImage(named: "star_empty")
            }
        }
    }
}
