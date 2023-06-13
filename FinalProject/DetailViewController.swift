import UIKit

class DetailViewController: UIViewController {

    var movieName : String?
    var starImageViews : [UIImageView] = []
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStackView()
        self.setSlider()
        
        if let name = movieName {
            print(name)
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
        slider.maximumValue = 5 // 최대값
        slider.minimumValue = 0 // 최소값
            // 실제로 slider는 사용자 눈에 보이지 않을 것이므로 모든 컬러는 clear로 설정
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
