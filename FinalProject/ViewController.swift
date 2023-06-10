//
//  ViewController.swift
//  FinalProject
//
//  Created by 컴퓨터공학부 on 2023/06/05.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
   
    var movieList: [[String]] = []
    var image = UIImage(imageLiteralResourceName: "poster_sample.jpg")
    var imageViews = [UIImageView]()
    
    //@IBOutlet weak var tableView: UITableView!
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
        //tableView.delegate = self
        //tableView.dataSource = self
    }
    
    func setupPopUpButton() {
        let popUpButtonClosure = { (action: UIAction) in
            print("Pop-up action")
        }
        
        dropButton.menu = UIMenu(children: [
            UIAction(title: "평가개수", handler: popUpButtonClosure),
            UIAction(title: "평균평점", handler: popUpButtonClosure)
        ])
        dropButton.showsMenuAsPrimaryAction = true
    }

    private func parseCSVAt(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                for item in dataArr {
                    movieList.append(item)
                }
            }
        } catch {
            print("Error reading CSV file")
        }
    }
    
    private func loadMovieFromCSV() {
        let path = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
        //self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CSVTableViewCell") as! CSVTableViewCell
        cell.textLabel?.text = movieList[indexPath.row][0]
        cell.detailTextLabel?.text = movieList[indexPath.row][1]
        return cell
    }
    
    private func addContentScrollView() {
        for i in 0..<movieList.count / 5 {
            for j in 0 ... 5 {
                let imageView = UIImageView()
                let xPos = scrollView.frame.width * CGFloat(i)
                let yPos = scrollView.bounds.height / 5 * CGFloat(j)
                imageView.frame = CGRect(x: xPos, y: yPos, width: scrollView.bounds.width / 4, height: scrollView.bounds.height / 5)
                imageView.image = image
                let textView = UITextView()
                textView.frame = CGRect(x: xPos + scrollView.bounds.width / 4, y: yPos, width: scrollView.bounds.width / 2, height: scrollView.bounds.height / 5)
                textView.text = movieList[i*5 + j][0]
                scrollView.addSubview(imageView)
                scrollView.addSubview(textView)
                scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1) * 2
            }
        }
        
    }
    
    private func setPageControl() {
        pageControl.numberOfPages = movieList.count / 20
        
    }
    
    private func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
}

