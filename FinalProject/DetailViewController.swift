import UIKit

class DetailViewController: UIViewController {

    var name:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("detail view controller")
        
        if let name = name {
            print(name)
        }        
    }
}
