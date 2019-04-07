## Phần 3 - Ví dụ về update dữ liệu :memo:
Phần này được viết tiếp theo của [Phần 2 - Ví dụ về thêm dữ liệu](CreationExample_vn.md). Trong phần này ta tái sử dụng service và model đã tạo ở phần 1 và giao diện thêm dữ liệu ở phần 2 để chỉnh sửa dữ liệu. Nếu trong quá trình đọc có phần nào không hiểu bạn có thể quay lại để đọc [Phần 1](ReadExample_vn.md) và [Phần 2](CreationExample_vn.md) trước.

#### **Bước 1:** Áp dụng protocol Updateable cho Model
Mở file `User.swift`, áp dụng protocol **Updateable** sau đó định nghĩa phương thức `idValue()` tương ứng với param id. Ngoài ra ta còn có thể định nghĩa lại `updateValue()` trong trường hợp có những param đặc biệt ngoài class (tương tự phương thức `createValue()` của protocol **Creatable**). 

```swift
extension User : Updateable {
    func idValue() -> String {
        return name
    }
}
```

#### **Bước 2:** Xử lý lại view model ở màn hình thêm dữ liệu

- **Bước 2.1:** Mở file `UserCreateViewModel.swift` và khai báo thêm input `userUpdatedEvent` để lắng nghe dữ liệu truyền vào từ view trong trường hợp người dùng update.

```swift
protocol UserCreateViewModelType {

    //MARK: Input
    ...
    var userUpdatedEvent: PublishSubject<User> {get}

    //MARK: Output
    ...

}
```
	
- **Bước 2.2:** Tại lớp **UserCreateViewModel**, định nghĩa thuộc tính `userUpdatedEvent` và thêm một biến `isUpdating` để biết màn hình đang ở trạng thái add hay update:

```swift
class UserCreateViewModel : UserCreateViewModelType {

    //MARK: Variable for output
    ...

    //MARK: Input
    ...
    lazy var userUpdatedEvent = PublishSubject<User>()

    //MARK: Output
    ...

    //MARK: Variables
    ...
    private var isUpdating = false

    ...
}
```

- **Bước 2.3:** Xử lý lưu lại thông tin user, bật cờ update và truyền tên, nghề nghiệp lên lại view khi có sự kiện update user từ view.

```swift
init() {

    ...

    //Setting for the update
    userUpdatedEvent.bind {[unowned self] (user) in
        self.user = user
        self.isUpdating = true
        self.nameString.onNext(user.name)
        self.jobString.onNext(user.job)
        self.addButtonEnable.value = true
    }.disposed(by: disposeBag)

}
```

- **Bước 2.4:** Thêm phương thức `updateUser()` để xử lý update thông tin của user lên server.

```swift
private func updateUser() {
    userService.update(object: self.user, responeType: User.self, completionHandler: { (result) in
        self.addButtonEnable.value = true
        switch(result) {
        case .success(let user):
            self.successString.onNext("Update was success!")
            break
        case .error(let err):
            self.errorString.onNext("Update was error!")
            break
        }

    })
}
```

- **Bước 2.5:** Thay đổi lại phần xử lý cho nút `save`, kiểm tra nếu đang update thì sẽ gọi phương thức `updateUser()`, ngược lại nếu thêm mới thì sẽ gọi phương thức `addUser()`.

```swift
 //Solve when the user tap on save button
addButtonTappedEvent.subscribe(onNext: {[unowned self] (_) in
    if self.isUpdating {
        self.updateUser()
    }else {
        self.addUser()
    }
}).disposed(by: disposeBag)
```


#### **Bước 3:** Chỉnh lại lớp UserCreateViewController
- **Bước 3.1:** Mở file `UserCreateViewController.swift`, thêm biến `updatingUser` để màn hình danh sách có thể truyền user muốn update dữ liệu vào phần **Public variables**

```swift
class UserCreateViewController: UIViewController {
    
    ...

    //MARK: Public variables
    var updatingUser: User?

    ...
}
```

- **Bước 3.2:** Tại `viewDidLoad()` kiểm tra nếu đang update thì sẽ truyền dữ liệu của user xuống cho view model. Và phần code này phải được viết sau khi gọi phương thức `bindViewModel()` vì biến lưu trữ dữ liệu `nameString` và `jobString` ta đã khai báo dạng **PublishSubject** trong class  **UserCreateViewModel** =>  dữ liệu sẽ không được lưu trữ => nếu gọi `bindViewModel()` sau thì sẽ không thể hiện thị dữ liệu lên trên view được.

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    //bindViewModel have to called before setupActions
    bindViewModel()
    setupActions()

    if let user = updatingUser {
        viewModel.userUpdatedEvent.onNext(user)
        self.nameTextField.isEnabled = false
    }
}
``` 


#### **Bước 4:** Xử lý chọn user
Vì sau này chúng ta có thể có các phần xử lý kiểm tra user trước khi cho chỉnh sửa (ví dụ kiểm tra user nếu là admin thì sẽ hiển thị thông báo và không cho chỉnh sửa), nên chúng ta sẽ truyền sự kiện chọn xuống view model và lắng nghe sự kiện chọn từ view model, sau đó mới xử lý chuyển màn hình trên view. Cụ thể như sau:
- **Bước 4.1:** Mở file `UserReadViewModel.swift`, khai báo input chọn user và output user đã được chọn cho protocol `UserReadViewModelType`:

```swift
protocol UserReadViewModelType {

    //MARK: Input
    ...
    var userSelectedEvent: PublishSubject<User> {get}

    //MARK: Output
    ...
    var userSelectedObservable: Observable<User> {get}

}
```

- **Bước 4.2:** Định nghĩa input và output tại lớp **UserReadViewModel** như sau:

```swift
class UserReadViewModel: UserReadViewModelType {

    //MARK: Variable for Output
    ...
    private var userSelected = PublishSubject<User>()

    //MARK: Input
    ...
    lazy var userSelectedEvent = PublishSubject<User>()

    //MARK: Output
    ...
    lazy var userSelectedObservable: Observable<User> = self.userSelected



    init() {

        ...

        //Listen when the user selected a person.
        userSelectedEvent.bind {[unowned self] (user) in
            //check available for update user info here
            self.userSelected.onNext(user)
        }.disposed(by: disposeBag)
    }
}
``` 

- **Bước 4.3:** Mở file `UserReadViewController.swift`, tại phương thức `setupActions()` xử lý truyền sự kiện chọn trên table view cho view model như sau:

```swift
func setupActions() {

    //call viewModel when the user selected cell in table view
    userTableView.rx.modelSelected(User.self).bind(to: viewModel.userSelectedEvent).disposed(by: disposeBag)

}
```

#### **Bước 5:** Xử lý chuyển màn hình
Để chuyển màn hình ta cần định nghĩa view controller trong storyboard trước.
- **Bước 5.1:** Mở file `Main.storyboard` --> Chọn view controller thêm dữ liệu --> gán `SIUserCreate` cho **Storyboard ID**
- **Bước 5.2:** Mở file UIStoryboardExtension.swift, đăng ký thêm 1 storyboardID trong `enum Identifier` với case là `userCreateVC` . Sau đó tạo ra phương thức `userCreateViewController()` để trả về view controller như sau:

```swift
extension UIStoryboard {

    struct Main {

        private enum Identifier : String, StoryboardScene {
            ...
            case userCreateVC = "SIUserCreate"
        }

        ...

        static func userCreateViewController() -> UIViewController {
            return Identifier.userCreateVC.viewController()
        }
    }

}
```

- **Bước 5.3:** Sau khi đã định nghĩa xong view controller ta sẽ mở file `UserReadViewController.swift` để xử lý chuyển màn hình khi người dùng đã chọn user tại phương thức `bindViewModel()` như sau:

```swift
func bindViewModel() {

    ...

    //Listen user selected and move to update screen
    viewModel.userSelectedObservable.bind {[unowned self] (user) in
        //Get create view controller
        let vc = UIStoryboard.Main.userCreateViewController() as! UserCreateViewController
        vc.updatingUser = user
        self.navigationController?.pushViewController(vc, animated: true)
    }.disposed(by: disposeBag)
}
```

Vì ta đã định nghĩa view controller ở file UIStoryboardExtension.swift, do đó ta chỉ cần gọi `UIStoryboard.Main.userCreateViewController() as! UserCreateViewController` thì nó sẽ khởi tạo 1 view controller có storyboardId khớp với storyboardId ta đã định nghĩa.

#### Cuối cùng: Chạy ứng dụng và xem kết quả :tada: :tada: :tada: 
Tiếp tục với [Phần cuối - Ví dụ về delete dữ liệu](DeletionExample_vn.md)
