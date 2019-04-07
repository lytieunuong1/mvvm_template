## Lưu ý đầu:
Trước khi bắt đầu thực hiện các dụngụ, nếu bạn chưa cài đặt code snippet của project cho Xcode của mình thì hãy xem và làm theo [hướng dẫn cài đặt code snippets](CodeSnippetTutorial_vn.md) để cho việc code được thuận tiện và nhanh chóng hơn.

## Phần 1 - Ví dụ hiển thị dữ liệu :page_facing_up:
Trong ví dụ này mình sử dụng [https://getsandbox.com/](https://getsandbox.com/) như là một server để cung cấp các API và lưu trữ dữ liệu. Trên server mình đã có sẵn một danh sách các thông tin user (bao gồm tên và nghề nghiệp).
Lưu ý: Các bạn có thể chỉnh sửa `baseURL` ở file **BaseAPIService.swift** để khớp với đường dẫn API của bạn. Ví dụ, chúng ta có 1 API read là `https://reqres.in/api/users`, thì ta sẽ có:
- `baseURL` : **`https://reqres.in/api/`**
- `resourceName` : **`users`** 

#### **Bước 1:** Chuẩn bị services
- **Bước 1.1:** Tạo 1 file swift đặt tên là `UserAPIService.swift` trong group **AppServices**.
- **Bước 1.2:** Mở file vừa tạo, gõ [code snippet](CodeSnippetTutorial_vn.md) là `mvvmapiserviceclass` để tạo lớp `UserAPIService` kế thừa từ `BaseAPIService`. Override phương thức `resourceName` để trả về resourceName tương ứng với API.

```swift
class UserAPIService: BaseAPIService {

    override func resourceName() -> String {
       return "users"
    }
}
```

#### **Bước 2:** Định nghĩa Model
Ví dụ dữ liệu server sẽ trả về danh sách user như sau:

```json
{
    "success": true,
    "message": "",
    "users": [
        {
            "name": "Thuy",
            "job": "Developer"
        }
    ]
}
```

Ta thấy danh sách user được trả về trong key **users**, đây chính là `pluralKeyPath` trong class model mà mình sẽ tạo. Tuy nhiên đây là key theo chuẩn nên ta không cần phải định nghĩa `pluralKeyPath`, thay vào đó ta chỉ cần định nghĩa `singularKeyPath` là **user** thì `pluralKeyPath` sẽ có giá trị mặc định là **users**.

Còn lại 2 key `success` và `message` là chuẩn chung của dữ liệu trả về và sẽ đc định nghĩa trong class **ResponeResult** trong file **AppResponeData.swift**. Nếu server trả về format khác thì ta chỉ cần vào file **AppResponeData.swift** và định nghĩa lại dữ liệu trả về.

Như dữ liệu phân tích ở trên ta sẽ có 1 class `User` và có 2 thuộc tính là `name` và `job`. Bạn có thể đọc thêm phần [Cách định nghĩa một model](ModelTutorial_vn.md) để hiểu sâu hơn. Tiếp theo chúng ta sẽ tiến hành tạo class model như sau:

- **Bước 2.1:** Tạo 1 file swift đặt tên là `User.swift` trong group **Models**.
- **Bước 2.2:** Mở file vừa tạo và gõ code snippet là `mvvmmodelclass` để tạo class `User`, class này sẽ kế thừa lớp **ModelType**.  

```swift
import EVReflection

class User : ModelType {

    //MARK: API Properties
    var name: String = ""
    var job: String = ""

    //MARK: Ignored Properties
    //properties will be ignored to write or read to/from json


    override class func singularKeyPath() -> String {
        return "user"
    }

}
``` 

#### **Bước 3:** Tạo View

- **Bước 3.1:** Mở file Main.storyboard và tạo 1 view controller có giao diện như hình bên dưới:

	![Read view interface](Images/re1.png)
	
- **Bước 3.2:** Tạo ra 1 group con nằm trong group `Features`, đặt tên là **Users**.
- **Bước 3.3:** Tạo ra 1 lớp con kế thừa từ **BaseViewController**, đặt tên là `UserReadViewController.swift` và nằm trong group **Users**.
- **Bước 3.4:** Kết nối lớp **UserReadViewController** tới view controller trên storyboard. Sau đó kéo IBOutlet cho table view đặt tên là `userTableView`.

```swift
class UserReadViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView!
    ...
}
```

- **Bước 3.5:** Tạo ra lớp con kế thừa từ lớp **UITableViewCell**, đặt tên là `UserTableViewCell` và nằm trong group **Users**.
- **Bước 3.6:** Kết nối lớp **UserTableViewCell** với table view cell và kéo IBOutlet cho `nameLabel` và `jobLabel` trên cell.

```swift
class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
}
```

- **Bước 3.7:** Xét `identifier` của cell bằng **cell**.


#### **Bước 4:** Tạo ViewModel
- **Bước 4.1:** Tạo 1 swift file, đặt tên là `UserReadViewModel.swift` trong group **Users**.
- **Bước 4.2:** Mở file vừa tạo và gọi import `RxCocoa` và `RxSwift`.
- **Bước 4.3:** Viết code snippet là `mvvmviewmodelprotocol` để tạo một protocol, đặt tên là `UserReadViewModelType` hoặc bất cứ tên gì bạn muốn nhưng nên theo [qui tắc đặt tên](Naming_vn.md#view-model). Protocol này được sử dụng để định nghĩa các input và các output trong view model. Như trong ví dụ này chúng ta chỉ cần hiển thị danh sách user vì vậy chúng ta không cần phải có input từ view.

**Lưu ý:** Nếu bạn chưa biết gì về RxSwift, bạn cần phải tìm hiểu về nó trước. Bạn có thể tham khảo [RxSwift For Dummies](http://swiftpearls.com/RxSwift-for-dummies-1-Observables.html) của **Michal Ciurus**.

```swift
protocol UserReadViewModelType {

    //MARK: Input

    //MARK: Output
    var userListObservable: Observable<[User]> {get}

}
```

- **Bước 4.4:** Tiếp theo ta sử dụng code snippet `mvvmviewmodelclass` để tạo ra 1 lớp kế thừa từ protocol trên. Sử dụng phương thức `userService.read()` để đọc dữ liệu từ server. 

```swift
class UserReadViewModel: UserReadViewModelType {

    //MARK: Variable for Output
    private var userList = Variable<[User]>([])

    //MARK: Input

    //MARK: Output
    lazy var userListObservable: Observable<[User]> = self.userList.asObservable()

    //MARK: Variables
    private let userService = UserAPIService()



    init() {

    	self.loadUser()

    }



    //MARK: Helpful functions
    private func loadUser() {
        userService.read(predicate: nil, responeType: User.self) {[weak self] (result) in
            switch (result) {
            case .success(let array):
                //update userList
                self?.userList.value = array
                break
            case .error(let error):
                //we can show message here
                break
            }
        }
    }

}
```


#### **Bước 5:** Tạo view model cho cell
- **Bước 5.1:** Tạo ra một file swift với tên là `UserCellViewModel` trong group **Users**.
- **Bước 5.2:** Mở file vừa tạo và viết code để định nghĩa các thông tin sẽ được hiển thị lên cell.

```swift
import RxSwift

struct UserCellViewModel {
    //MARK: Output
    let nameString = BehaviorSubject<String>(value: "")
    let jobString = BehaviorSubject<String>(value: "")


    
    init(user: User) {
        nameString.onNext(user.name)
        jobString.onNext(user.job)
    }
}
```


#### **Bước 6:** Truyền dữ liệu từ View Model lên View
- **Bước 6.1:** Mở file `UserTableViewCell`, import `RxSwift` sau đó trong class **UserTableViewCell** sử dụng code snippet `mvvmtableviewcellclass` để sinh ra code mẫu, tại đây ta sẽ định nghĩa class của `viewModel` và truyền dữ liệu từ view model lên cell trong phương thức `bindViewModel()` như sau:

```swift
import RxSwift

class UserTableViewCell: UITableViewCell {
    ...

    private var disposeBag = DisposeBag()

    //Use a trigger that when the viewModel change we will register observers to show data into view
    var viewModel: UserCellViewModel? {
        didSet {
            bindViewModel()
        }
    }



    override func prepareForReuse() {
        super.prepareForReuse()
        //You have to re-create a new DisposeBag to clear the old observers
        disposeBag = DisposeBag()
    }



    func bindViewModel() {

        viewModel?.jobString.bind(to: jobLabel.rx.text).disposed(by: disposeBag)

        viewModel?.nameString.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
    }
}
```

- **Bước 6.2:** Mở file `UserReadViewController`, import `RxSwift` sau đó vào trong class **UserReadViewController** xoá đoạn code phương thức `viewDidLoad()` đi và sử dụng code snippet `mvvmviewcontroller` để sinh ra code mẫu. Sau đó viết code trong phương thức `bindViewModel()` để truyền dữ liệu từ view model lên view như sau:

```swift
import RxSwift

class UserReadViewController: UIViewController {

    ...
    
    //MARK: Private variables
    private let viewModel: UserReadViewModelType = UserReadViewModel()
    private let disposeBag = DisposeBag()

    //MARK: Public variables




    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        setupActions()
    }



    //MARK: Bind Output data from viewModel
    func bindViewModel() {

        viewModel.userListObservable.bind(to: userTableView.rx.items(cellIdentifier: "cell", cellType: UserTableViewCell.self)) {
            index, item, cell in
            //set viewModel for cell => the same with show data to cell
            cell.viewModel = UserCellViewModel(user: item)
        }.disposed(by: disposeBag)

    }



    //MARK: Map UI's actions to Input of the viewModel
    func setupActions() {

        
    }



     //MARK: Helpful functions

}
```


#### Cuối cùng: Chạy ứng dụng và xem kết quả :tada: :tada: :tada: 
Tiếp tục với [Phần 2 - Ví dụ về thêm dữ liệu](CreationExample_vn.md)
