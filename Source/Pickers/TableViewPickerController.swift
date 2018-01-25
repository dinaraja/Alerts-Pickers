import UIKit

public extension UIAlertController {
  func addTableViewPicker(type: TableViewPickerController.Kind,
                          dataArray: [PickerInfo],
                          action: TableViewPickerController.Action?) {
    let vc = TableViewPickerController(
        type: type,
        dataArray: dataArray,
        action: action
    )
    set(vc: vc)
  }
}

public struct PickerInfo {
  public var id: String
  public var title: String
  public var image: UIImage?

  public init(id: String, title: String, image: UIImage? = nil) {
    self.id = id
    self.title = title
    self.image = image
  }
}

public final class TableViewPickerController: UIViewController {
  struct UI {
    static let rowHeight = CGFloat(50)
  }

  public typealias Action = (PickerInfo) -> Swift.Void

  public enum Kind {
    case title
    case imageAndTitle
  }

  fileprivate lazy var tableView: UITableView = {
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = nil
    $0.tableFooterView = UIView()
    $0.rowHeight = UI.rowHeight
    $0.separatorColor = UIColor.lightGray.withAlphaComponent(0.4)
    $0.separatorInset = .zero
    $0.bounces = true
    return $0
  }(UITableView(frame: .zero, style: .plain))

  fileprivate let type: Kind
  fileprivate let action: Action?
  fileprivate let pickerInfoArray: [PickerInfo]
  fileprivate var dataSource: [CellData] = []

  // MARK: Initialize
  public required init(type: Kind, dataArray: [PickerInfo], action: Action?) {
    self.type = type
    self.pickerInfoArray = dataArray
    self.action = action
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    Log("has deinitialized")
  }

  override public func loadView() {
    view = tableView
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    switch type {
      case .title:
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: String(describing: UITableViewCell.self)
        )
      case .imageAndTitle:
        tableView.register(
            CountryTableViewCell.self,
            forCellReuseIdentifier: CountryTableViewCell.identifier
        )
    }

    updateDataSource()
  }

  func updateDataSource() {
    DispatchQueue.global(qos: .userInitiated).async {
      self.reloadDataSource()

      DispatchQueue.main.async {
        self.preferredContentSize.height = UIScreen.main.bounds.height
        self.tableView.reloadData()
      }
    }
  }

  func reloadDataSource() {
    dataSource.removeAll()
    dataSource = pickerInfoArray
        .map { pickerInfo in
      let config: CellConfig = { [unowned self] cell in
        cell?.textLabel?.text = pickerInfo.title

        if self.type == .imageAndTitle {
          DispatchQueue.main.async {
            let size = CGSize(width: 32, height: 24)
            let cellImage = pickerInfo.image?.imageWithSize(size: size, roundedRadius: 3)
            cell?.imageView?.image = cellImage
            cell?.imageView?.cornerRadius = 3
            cell?.imageView?.maskToBounds = true
            cell?.setNeedsLayout()
            cell?.layoutIfNeeded()
          }
        }
      }

      let action: CellConfig = { [unowned self] cell in
        self.action?(pickerInfo)
      }
      return CellData(config: config, action: action)
    }
  }
}

// MARK: - TableViewDelegate
extension TableViewPickerController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dataSource[indexPath.row]
        .action?(tableView.cellForRow(at: indexPath))
  }
}

// MARK: - TableViewDataSource
extension TableViewPickerController: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch type {
      case .title:
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))!
        dataSource[indexPath.row]
            .config?(cell)
        return cell
      case .imageAndTitle:
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.identifier) as! CountryTableViewCell
        dataSource[indexPath.row]
            .config?(cell)
        return cell
    }
  }
}
