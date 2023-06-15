import UIKit
import SwiftSoup

class DetailViewController: UIViewController {

    var movieName : String?
    var movieStar : Float?
    var starImageViews : [UIImageView] = []
    var movieList: [[String]] = []
    var starList: [[String]] = []
    var reviewList: [[String]] = []
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        LoadingView.showLoading()
        super.viewDidLoad()
        self.loadMovieFromCSV()
        self.loadStarDataFromCSV()
        self.setStackView()
        self.setSlider()
        self.findMovieData()
        self.getReview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            LoadingView.hideLoading()
            //print(self.reviewList)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.saveStarData()
    }
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata3", ofType: "csv")!
        parseMovieDataAt(url: URL(fileURLWithPath: path))
    }
    
    private func parseMovieDataAt(url: URL) {
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
    }
    
    func findMovieData() { //정보 가져오기
        for i in 0 ..< movieList.count {
            if(movieList[i][1] == movieName) {
                //label 바꾸고 .. 등등
                print(movieList[i][1])
                break
            }
            if(i==movieList.count - 1) {
                print("error - no name")
            }
        }
        
        for i in 0 ..< starList.count {
            if(starList[i][0] == movieName) {
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
        var newData : String = "0"
        for i in 0 ..< starList.count {
            if(starList[i][0] == movieName) {
                starList[i][1] = String(slider.value)
            }
            let data = starList[i].joined(separator: ",")
            if(i == 0) { newData = data }
            else { newData.append(data) }
            newData.append("\n")
        }
        
        do {
            let path = Bundle.main.path(forResource: "starData", ofType: "csv")!
            try newData.write(to: URL(fileURLWithPath: path), atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
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
    
    func getReview() {
        let imdbID = "tt1298650"
        let urlPath = "https://www.imdb.com/title/\(imdbID)/reviews?ref_=tt_urv"
        let url = NSURL(string: urlPath)
        //let titleClassPath = "#main > section > div.lister > div.lister-list > div:nth-child(1) > div.review-container > div.lister-item-content > a"
        //let contentClassPath = "#main > section > div.lister > div.lister-list > div:nth-child(1) > div.review-container > div.lister-item-content > div.content > div"
        let session = URLSession.shared
        let task = session.dataTask(with: url! as URL, completionHandler: {(data, response, error) -> Void in
            if error == nil {
                let urlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                //print(urlContent)
                
                do {
                    let doc: Document = try SwiftSoup.parse(urlContent as String)
                    let elements: Elements = try doc.select("#main > section > div.lister > div.lister-list > div")
                    for element in elements {
                        let title = try element.select("div.review-container > div.lister-item-content > a").text()
                        let contents = try element.select("div.review-container > div.lister-item-content > div.content > div").text()
                        self.reviewList.append([title, contents])
                    }

                } catch {
                    print(error)
                }
                
            } else {
                print("error occurred")
            }
        })
        task.resume()
    }
}
