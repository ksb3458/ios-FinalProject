import UIKit
import SwiftSoup

class DetailViewController: UIViewController, UIScrollViewDelegate {

    var movieName : String?
    var movieInfo : [String] = []
    var movieStar : Float?
    var starImageViews : [UIImageView] = []
    var movieList: [[String]] = []
    var starList: [[String]] = []
    var reviewList: [[String]] = []
    var actorList: [[String]] = []
    var crewList: [[String]] = []
    var actorAnotherList: [[String]] = []
    var directorAnotherList: [[String]] = []
    var extraBtnNum : Int = 0
    var review1Num : Int = 0
    var review2Num : Int = 0
    var review3Num : Int = 0
    var review4Num : Int = 0
    var review5Num : Int = 0
    var str : String?
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var labelLine: UILabel!
    @IBOutlet weak var labelLine2: UIView!
    @IBOutlet weak var overviewBtn: UIButton!
    @IBOutlet weak var extraText: UITextView!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var actorStackView: UIStackView!
    @IBOutlet weak var actorLabel: UILabel!
    
    @IBOutlet weak var review1: UITextView!
    @IBOutlet weak var review2: UITextView!
    @IBOutlet weak var review3: UITextView!
    @IBOutlet weak var review4: UITextView!
    @IBOutlet weak var review5: UITextView!
    
    @IBOutlet weak var actorAnotherView: UIView!
    @IBOutlet weak var actorScrollView: UIScrollView!
    @IBOutlet weak var directorAnotherView: UIView!
    @IBOutlet weak var directorScrollView: UIScrollView!
    @IBOutlet weak var directorAnotherLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingView.showLoading()
        self.actorLabel.isHidden = true
        self.loadMovieFromCSV()
        //self.loadActorFromCSV()
        self.loadCrewFromCSV()
        self.loadStarDataFromCSV()
        self.setStackView()
        self.setSlider()
        self.findMovieData()
        self.extraText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.extraTextTapped)))
        self.overviewText.text = str
        self.shrinkExtraText()
        self.getReview()
        actorScrollView.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            LoadingView.hideLoading()
            self.initReviewState()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initOverviewText()
        self.initExpandButton()
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
                movieInfo = movieList[i]
                posterImageView.image = image
                titleLabel.text = movieList[i][1]
                titleLabel.adjustsFontSizeToFitWidth = true
                dateLabel.text = movieList[i][13]
                let time = Int(movieList[i][15])
                timeLabel.text = "\(time!/60)H \(time!%60)M"
                var genreData : [String] = []
                var genre : [String] = []
                let dataArr = movieList[i][3].components(separatedBy: "\"[").map({$0.components(separatedBy: ",")})
                for item in dataArr {
                    genreData.append(contentsOf: item)
                }
                for i in stride(from: 2, to: genreData.count, by: 2) {
                    var str : [String]
                    str = genreData[i].components(separatedBy: ": ")
                    genre.append(String(str[1].dropLast(1)))
                }
                genreLabel.text = "\(genre[0]), \(genre[1]), \(genre[2])"
                avgLabel.text = movieList[i][20]
                str = movieList[i][9] + "\""
                let director = movieList[i][22].dropLast(1).dropFirst(1)
                directorLabel.text = String(director)
                setActorStack()
                getActorAnotherData()
                getDirectorAnotherData()
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
            imageView.frame = CGRect(x: xPos, y: yPos, width: (imageView.image?.size.width)! / 22, height: (imageView.image?.size.height)! / 22)
            stackView.addSubview(imageView)
            starImageViews.append(stackView.subviews[i] as? UIImageView ?? UIImageView())
        }
    }
    
    func setActorStack() {
        for i in 23..<movieInfo.count {
            let label = UILabel()
            if i == 23 {label.text = String(movieInfo[i].dropFirst(1).dropLast(1))}
            else { label.text = ", " + String(movieInfo[i].dropFirst(1).dropLast(1))}
            actorStackView.addArrangedSubview(label)
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
        let imdbID = movieInfo[6]
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
    
    private func initOverviewText() {
        overviewText.textContainer.maximumNumberOfLines = 3
        overviewText.textContainer.lineBreakMode = .byTruncatingTail
    }
    
    private func initExpandButton() {
        let lineCount = (overviewText.contentSize.height - overviewText.textContainerInset.top - overviewText.textContainerInset.bottom) / overviewText.font!.lineHeight
        print(lineCount)
        if lineCount <= 3 {
            overviewBtn.isHidden = true
        }
    }
    
    @IBAction func touchExpandButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            overviewText.text = str
            overviewText.textContainer.maximumNumberOfLines = 0
            overviewText.invalidateIntrinsicContentSize()
            overviewText.translatesAutoresizingMaskIntoConstraints = true
            overviewText.sizeToFit()
            overviewText.isScrollEnabled = false
        } else {
            // 접기
            overviewText.text = str
            overviewText.textContainer.maximumNumberOfLines = 3
            overviewText.invalidateIntrinsicContentSize()
            overviewText.translatesAutoresizingMaskIntoConstraints = false
            overviewText.sizeToFit()
            overviewText.isScrollEnabled = true

        }
    }
    
    private func expandExtraText() {
        let originalString = "추가 정보    >\n원제         \(movieInfo[8])\n상태         \(movieInfo[15])\n원어          \(movieInfo[7])\n제작비     \(movieInfo[2])\n수익         \(movieInfo[14])\n"
        let attributedString = NSMutableAttributedString(string: originalString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 15
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        let range0 = (originalString as NSString).range(of: "추가 정보")
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range0)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 21, weight: .semibold), range: range0)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle2, range: range0)
        let range1 = (originalString as NSString).range(of: "원제")
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range1)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: range1)
        let range2 = (originalString as NSString).range(of: "상태")
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range2)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: range2)
        let range3 = (originalString as NSString).range(of: "원어")
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range3)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: range3)
        let range4 = (originalString as NSString).range(of: "제작비")
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range4)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: range4)
        let range5 = (originalString as NSString).range(of: "수익")
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range5)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: range5)
        
        extraText.attributedText = attributedString
        extraText.textContainer.maximumNumberOfLines = 0
        extraText.invalidateIntrinsicContentSize()
        extraText.translatesAutoresizingMaskIntoConstraints = true
        extraText.sizeToFit()
        extraText.isScrollEnabled = false
    }
    
    private func shrinkExtraText() {
        let originalString = "추가 정보    V"
        let attributedString = NSMutableAttributedString(string: originalString)
        let range0 = (originalString as NSString).range(of: "추가 정보")
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range0)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 21, weight: .semibold), range: range0)
        
        extraText.attributedText = attributedString
        extraText.textContainer.maximumNumberOfLines = 1
        extraText.invalidateIntrinsicContentSize()
        extraText.translatesAutoresizingMaskIntoConstraints = false
        extraText.sizeToFit()
    }
    
    @objc func extraTextTapped(_ sender: UITapGestureRecognizer) {
        if extraBtnNum % 2 == 0 {
            expandExtraText()
        }
        if extraBtnNum % 2 == 1 {
            shrinkExtraText()
        }
        extraBtnNum += 1
    }
    
    private func initReviewState() {
        self.review1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.review1TextTapped)))
        self.review2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.review2TextTapped)))
        self.review3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.review3TextTapped)))
        self.review4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.review4TextTapped)))
        self.review5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.review5TextTapped)))
        
        shrinkReview(review: review1, index: 0)
        shrinkReview(review: review2, index: 1)
        shrinkReview(review: review3, index: 2)
        shrinkReview(review: review4, index: 3)
        shrinkReview(review: review5, index: 4)
    }
    
    private func expandReview(review : UITextView, index : Int) {
        let originalString = reviewList[index][0] + "\n" + reviewList[index][1]
        let attributedString = NSMutableAttributedString(string: originalString)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: NSRange(location: 0, length: attributedString.length))
        let range0 = (originalString as NSString).range(of: reviewList[index][0])
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range0)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .semibold), range: range0)
        
        review.attributedText = attributedString
        review.textContainer.maximumNumberOfLines = 0
        review.invalidateIntrinsicContentSize()
        review.translatesAutoresizingMaskIntoConstraints = true
        review.sizeToFit()
        review.isScrollEnabled = false
    }
    
    private func shrinkReview(review : UITextView, index : Int) {
        let originalString = reviewList[index][0]
        let attributedString = NSMutableAttributedString(string: originalString)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .semibold), range: NSRange(location: 0, length: attributedString.length))
        
        review.attributedText = attributedString
        review.textContainer.maximumNumberOfLines = 2
        review.invalidateIntrinsicContentSize()
        review.translatesAutoresizingMaskIntoConstraints = false
        review.sizeToFit()
        review.isScrollEnabled = true
    }
    
    @objc func review1TextTapped(_ sender: UITapGestureRecognizer) {
        if review1Num % 2 == 0 {
            expandReview(review: review1, index: 0)
        }
        if review1Num % 2 == 1 {
            shrinkReview(review: review1, index: 0)
        }
        review1Num += 1
    }
    
    @objc func review2TextTapped(_ sender: UITapGestureRecognizer) {
        if review2Num % 2 == 0 {
            expandReview(review: review2, index: 1)
        }
        if review2Num % 2 == 1 {
            shrinkReview(review: review2, index: 1)
        }
        review2Num += 1
    }
    
    @objc func review3TextTapped(_ sender: UITapGestureRecognizer) {
        if review3Num % 2 == 0 {
            expandReview(review: review3, index: 2)
        }
        if review3Num % 2 == 1 {
            shrinkReview(review: review3, index: 2)
        }
        review3Num += 1
    }
    
    @objc func review4TextTapped(_ sender: UITapGestureRecognizer) {
        if review4Num % 2 == 0 {
            expandReview(review: review4, index: 3)
        }
        if review4Num % 2 == 1 {
            shrinkReview(review: review4, index: 3)
        }
        review4Num += 1
    }
    
    @objc func review5TextTapped(_ sender: UITapGestureRecognizer) {
        if review5Num % 2 == 0 {
            expandReview(review: review5, index: 4)
        }
        if review5Num % 2 == 1 {
            shrinkReview(review: review5, index: 4)
        }
        review5Num += 1
    }
    
    private func getActorAnotherData() {
        let actor1 = movieInfo[23]
        let actor2 = movieInfo[24]
        let actor3 = movieInfo[25]
        
        for i in 0 ..< movieList.count {
            for j in 23 ..< movieList[i].count {
                if movieList[i][j] == actor1 || movieList[i][j] == actor2 || movieList[i][j] == actor3 {
                    if movieList[i][1] != movieInfo[1] {
                        actorAnotherList.append(movieList[i])
                    }
                    break
                }
            }
        }
        addActorScrollView()
    }
    
    private func addActorScrollView() {
        for i in 0 ..< actorAnotherList.count {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: CGFloat(i) * 120 + CGFloat(10*i), y: 0, width: actorAnotherView.bounds.width / 6.3, height: actorAnotherView.bounds.height / 4 * 3)
            imageView.image = image
            let label = UILabel()
            label.frame = CGRect(x: CGFloat(i) * 120 + CGFloat(10*i), y: 136, width: imageView.bounds.width - 10, height: actorAnotherView.bounds.height / 4)
            label.text = actorAnotherList[i][1]
            
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewHotTapped)))
            label.tag = i
            label.isUserInteractionEnabled = true
            //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewHotTapped)))
            
            actorAnotherView.addSubview(imageView)
            actorAnotherView.addSubview(label)
            actorScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
    }
    
    private func getDirectorAnotherData() {
        let director = movieInfo[22]
        for i in 0 ..< movieList.count {
            if movieList[i][22] == director {
                if movieList[i][1] != movieInfo[1] {
                    directorAnotherList.append(movieList[i])
                }
                break
            }
        }
        addDirectorScrollView()
    }
    
    private func addDirectorScrollView() {
        if directorAnotherList.count == 0 {
            directorAnotherLabel.isHidden = true
            directorScrollView.isHidden = true
            directorAnotherView.isHidden = true
        }
        
        for i in 0 ..< directorAnotherList.count {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: CGFloat(i) * 120 + CGFloat(10*i), y: 0, width: directorAnotherView.bounds.width / 4, height: directorAnotherView.bounds.height / 4 * 3)
            imageView.image = image
            let label = UILabel()
            label.frame = CGRect(x: CGFloat(i) * 120 + CGFloat(10*i), y: 136, width: imageView.bounds.width - 10, height: directorAnotherView.bounds.height / 4)
            label.text = directorAnotherList[i][1]
            
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewHotTapped)))
            label.tag = i
            label.isUserInteractionEnabled = true
            //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewHotTapped)))
            
            directorAnotherView.addSubview(imageView)
            directorAnotherView.addSubview(label)
            directorScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
    }
}
