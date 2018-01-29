import UIKit

extension UIAlertController {

  /// Add a textView
  ///
  /// - Parameters:
  ///   - height: textView height
  ///   - hInset: right and left margins to AlertController border
  ///   - vInset: bottom margin to button

  func addOneTextView(textView: UITextView) {
    let textViewController = OneTextViewViewController(
        vInset: preferredStyle == .alert ? 12 : 0,
        textView: textView
    )
    let height: CGFloat = OneTextViewViewController.ui.height + OneTextViewViewController.ui.vInset
    set(vc: textViewController, height: height)
  }
}

public final class OneTextViewViewController: UIViewController {

  fileprivate var textView: UITextView!

  struct ui {
    static let height: CGFloat = 100
    static let hInset: CGFloat = 12
    static var vInset: CGFloat = 12
  }


  init(vInset: CGFloat = 12, textView: UITextView) {
    super.init(nibName: nil, bundle: nil)
    self.textView = textView

    view.addSubview(textView)
    ui.vInset = vInset

    /// have to set textView frame width and height to apply cornerRadius
    textView.height = ui.height
    textView.width = view.width

    preferredContentSize.height = ui.height + ui.vInset
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    Log("has deinitialized")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    textView.width = view.width - ui.hInset * 2
    textView.height = ui.height
    textView.center.x = view.center.x
    textView.center.y = view.center.y - ui.vInset / 2
  }
}
