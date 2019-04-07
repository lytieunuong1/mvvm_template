Ngoài việc tuân theo [quy tắc đặt tên chuẩn](https://swift.org/documentation/api-design-guidelines/#naming) của apple ta sẽ tuân theo một số quy tắc đặt tên bên dưới để dễ dàng cho việc đọc hiểu và quản lý code của nhau.

Các quy tắc được viết theo các phần lớn sau bao gồm:
- [Service](#service)
- [Model](#model)
- [View Model](#view-model)
- [View](#view)


## Service
- Các service trong ứng dụng đều được tạo trong group **AppServices**
- Tên class sẽ được đặt theo tên của API và thêm `APIService` phía cuối ==> `[APIName]APIService`. Ví dụ như UserAPIService
- Các class này sẽ phải kế thừa từ class **BaseAPIService** để có sẵn các phương thức CRUD và đều phải override lại phương thức `resourceName()` để trả về resource name tương ứng.

Ví dụ:

```swift
class UserAPIService: BaseAPIService {

    override func resourceName() -> String {
       return "users"
    }
   
}
```

## Model
- Để model có thể parse từ kết quả trả về của API thì class phải implement protocol `Mappable` của thư viện ObjectMapper
- Để cho phép thêm dữ liệu thì class phải implement protocol `Creatable`
- Để cho phép chỉnh sửa, xoá, hoặc lấy ra thông tin chi tiết dựa vào id thì phải implement protocol `Updateable`


## View Model
Một view model thường sẽ đc đặt theo view và thêm `ViewModel` phía cuối ==> `[ViewName]ViewModel`
1. Protocol
- Đặt tên protocol sẽ dựa vào tên của view model và thêm chữ `Type` phía cuối để phân biệt. ==> `[ViewName]ViewModelType`
- Cấu trúc của protocol sẽ như sau:

```swift
protocol XXXViewModelType {

    //MARK: Input


    //MARK: Output
    
}
```

- Các input sẽ có từ khoá `Event` ở phía đuôi
- Các output sẽ có từ khoá `Observable` ở phía đuôi
Ví dụ:

```swift
protocol UserReadViewModelType {

    //MARK: Input
    var deleteButtonTappedEvent: PublishSubject<Void> {get}
    var userSelectedEvent: PublishSubject<User> {get}
    var reloadUserListEvent: PublishSubject<Void> {get}
    var deletedUserEvent: PublishSubject<IndexPath> {get}

    //MARK: Output
    var selectedDeleteButtonObservable: Observable<Bool> {get}
    var userListObservable: Observable<[User]> {get}
    var userSelectedObservable: Observable<User> {get}

}
```

2. Class
- Class sẽ định nghĩa các thuộc tính được khai báo trên protocol và có tên là `[ViewName]ViewModel`
- Cấu trúc của class sẽ như sau:

```swift
class XXXViewModel: XXXViewModelType {

    //MARK: Variable for Output

    //MARK: Input

    //MARK: Output

    //MARK: Variables
    
    init() {

        //respone events from view

    }

    //MARK: Helpful functions

}
```

Ví dụ:

```swift
class UserReadViewModel: UserReadViewModelType {

    //MARK: Variable for Output
    private var selectedDeleteButton = Variable<Bool>(false)
    private var userList = Variable<[User]>([])
    private var userSelected = PublishSubject<User>()

    //MARK: Input
    lazy var deleteButtonTappedEvent = PublishSubject<Void>()
    lazy var userSelectedEvent = PublishSubject<User>()
    lazy var reloadUserListEvent = PublishSubject<Void>()
    lazy var deletedUserEvent = PublishSubject<IndexPath>()

    //MARK: Output
    lazy var selectedDeleteButtonObservable: Observable<Bool> = self.selectedDeleteButton.asObservable()
    lazy var userListObservable: Observable<[User]> = self.userList.asObservable()
    lazy var userSelectedObservable: Observable<User> = self.userSelected

    //MARK: Variables
    private let userService = UserAPIService()
    private let disposeBag = DisposeBag()



    init() {

        //Listen refresh data requirement from UI
        reloadUserListEvent.bind {[unowned self] in
            self.loadUser()
        }.disposed(by: disposeBag)

        deleteButtonTappedEvent.bind {[unowned self] in
            self.selectedDeleteButton.value = !self.selectedDeleteButton.value
        }.disposed(by: disposeBag)

        //Listen the deleted person.
        deletedUserEvent.bind {[unowned self] (indexPath) in
            self.deleteUser(at: indexPath)
        }.disposed(by: disposeBag)

        //Listen when the user selected a person.
        userSelectedEvent.bind {[unowned self] (user) in
            self.userSelected.onNext(user)
        }.disposed(by: disposeBag)

    }



    //MARK: Helpful functions
    func deleteUser(at indexPath: IndexPath) {
        let user = self.userList.value[indexPath.row]
        userService.delete(object: user, responeType: User.self) {[unowned self] (result) in
            switch (result) {
            case .success(_):
                //Remove the person in list after deleted at server.
                 self.userList.value.remove(at: indexPath.row)
                break
            case .error(let error):
                //we can show message here
                print("Delete user got an error: " + error)
                break
            }
        }
    }



    func loadUser() {
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

## View
- view model phải luôn được khai báo dưới dạng `Type Inference` với protocol:

```swift
private let viewModel: UserReadViewModelType = UserReadViewModel()
```

Để tránh trường hợp bị confused khi lớp view model được tái sử dụng cho nhiều view thì thông qua protocol sẽ che hết các phương thức và thuộc tính không liên quan tới view đó.

- Cấu trúc của class View Controller sẽ như sau:

```swift
class XXXViewController: UIViewController {

    //MARK: UI variables

    //MARK: Private variables

    //MARK: Public variables

    override func viewDidLoad() {
        super.viewDidLoad()
        //bindViewModel have to called before setupActions
        bindViewModel()
        setupActions()
    }


    //MARK: Bind Output data from viewModel
    func bindViewModel() {
        //Bind viewModel's outputs here
    }


    //MARK: Map UI's actions to Input of the viewModel
    func setupActions() {
        //Map UI's actions to viewModel's inputs here
    }


    

    //MARK: Helpful functions

}
```

    - Phương thức `bindViewModel()` sẽ thực hiện việc hiển thị dữ liệu từ các output của viewModel.
    - Phương thức `setupActions()` sẽ thực hiện việc truyền các sự kiện trên view xuống cho các input của viewModel.




