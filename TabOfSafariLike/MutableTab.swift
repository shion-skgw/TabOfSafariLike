//
//  MutableTab.swift
//  TabOfSafariLike
//
//  Created by Shion on 2020/09/27.
//

import UIKit

final class MutableTabController: UIViewController {

    weak var tabs: TabView!
    weak var container: UIView!

    var tabHeight: CGFloat = UIFont.systemFontSize * 2

    var currentTagNumber = 0
    var nextTagNumber: Int {
        currentTagNumber += 1
        return currentTagNumber
    }

    override func viewDidLoad() {
//        print("\(type(of: self)): \(#function) start")

        super.viewDidLoad()

        let tabs = TabView()
        tabs.showsVerticalScrollIndicator = false
        tabs.showsHorizontalScrollIndicator = false
        tabs.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        tabs.tabContainer.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        view.addSubview(tabs)
        self.tabs = tabs

        let container = UIView()
        container.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        view.addSubview(container)
        self.container = container

//        print("\(type(of: self)): \(#function) end")
    }

    override func viewDidLayoutSubviews() {
//        print("\(type(of: self)): \(#function) start")

        super.viewDidLayoutSubviews()

        tabs.frame = CGRect(origin: .zero, size: view.bounds.size)
        tabs.frame.size.height = tabHeight

        container.frame = CGRect(origin: .zero, size: view.bounds.size)
        container.frame.origin.y += tabHeight
        container.frame.size.height -= tabHeight

//        print("\(type(of: self)): \(#function) end")
    }

    @objc func selectTab(sender: TabItem) {
        print("\(type(of: self)): \(#function) sender=\(sender.tag)")

        tabs.tabContainer.subviews.forEach({ ($0 as? TabItem)?.isActive = $0.tag == sender.tag })
        container.subviews.forEach({ $0.isHidden = $0.tag != sender.tag })

        print("\(type(of: self)): \(#function) viewController=\(children.count), container=\(container.subviews.count)")
    }

    @objc func closeTab(sender: UIButton) {
        print("\(type(of: self)): \(#function) sender=\(sender.tag)")

        guard let tab = tabs.tabContainer.subviews.filter({ $0.tag == sender.tag }).first as? TabItem,
                let child = children.filter({ $0.view.tag == sender.tag }).first else {
            return
        }
        tabs.remove(item: tab)
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

        if container.subviews.filter({ !$0.isHidden }).isEmpty,
                let lastAddView = container.subviews.max(by: { $0.tag < $1.tag }) {
            lastAddView.isHidden = false
            tabs.tabContainer.subviews.forEach({ ($0 as? TabItem)?.isActive = $0.tag == lastAddView.tag })
        }

        print("\(type(of: self)): \(#function) viewController=\(children.count), container=\(container.subviews.count)")
    }

    func addTeb(title: String, viewController: UIViewController) {
        print("\(type(of: self)): \(#function) title=\(title)")

        let tagNumber = nextTagNumber

        // Add child, sub view
        viewController.view.tag = tagNumber
        addChild(viewController)
        container.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        // Add tab
        let tab = TabItem(frame: .zero)
        tab.set(title: title, font: .systemFont(ofSize: UIFont.systemFontSize), fontColor: .black)
        tab.set(activeColor: UIColor(white: 0.5, alpha: 1.0), inactiveColor: UIColor(white: 0.3, alpha: 1.0))
        tab.set(tabHeight: tabHeight)
        tab.set(tagNumber: tagNumber)
        tab.addTarget(self, action: #selector(selectTab(sender:)), for: .touchUpInside)
        tab.closeButton.addTarget(self, action: #selector(closeTab(sender:)), for: .touchUpInside)
        tabs.add(item: tab)

        tabs.tabContainer.subviews.forEach({ ($0 as? TabItem)?.isActive = $0.tag == tagNumber })
        container.subviews.forEach({ $0.isHidden = $0.tag != tagNumber })

        print("\(type(of: self)): \(#function) viewController=\(children.count), container=\(container.subviews.count)")
    }

}

final class TabView: UIScrollView {

    weak var tabContainer: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialize UIStackView
        let tabContainer = UIStackView(frame: .zero)
        tabContainer.distribution = .fill
        tabContainer.axis = .horizontal
        tabContainer.alignment = .center
        tabContainer.spacing = 1
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabContainer)
        self.tabContainer = tabContainer

        // Layout anchor setting
        self.topAnchor.constraint(equalTo: tabContainer.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: tabContainer.heightAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(item: TabItem) {
        tabContainer.addArrangedSubview(item)
    }

    func remove(item: TabItem) {
        tabContainer.removeArrangedSubview(item)
        item.removeFromSuperview()
    }

}

final class TabItem: UIButton {

    let horizontalMargin: CGFloat = 6
    var tabHeight: CGFloat = UIFont.systemFontSize * 2
    var activeColor: UIColor = .white
    var inactiveColor: UIColor = .white
    weak var closeButton: UIButton!

    var isActive: Bool = true {
        didSet {
            self.backgroundColor = isActive ? activeColor : inactiveColor
        }
    }

    override var intrinsicContentSize: CGSize {
        self.frame.size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let closeButton = UIButton(type: .close)
        addSubview(closeButton)
        self.closeButton = closeButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        // Close button
        closeButton.frame.origin.x = horizontalMargin
        closeButton.frame.origin.y = (tabHeight - closeButton.frame.height) / 2

        // Title label
        if let titleLabel = titleLabel {
            let title = titleLabel.text ?? ""
            let font = titleLabel.font ?? .systemFont(ofSize: 12)
            titleLabel.frame.size = NSAttributedString(string: title, attributes: [ .font: font ]).size()
            titleLabel.frame.origin.x = closeButton.frame.width + horizontalMargin * 2
            titleLabel.frame.origin.y = (tabHeight - titleLabel.frame.height) / 2.0
        }

        // Self
        frame.size.width = closeButton.frame.width + (titleLabel?.frame.width ?? 0.0) + horizontalMargin * 3.0 + 3.0
        frame.size.height = tabHeight
    }

    func set(title: String, font: UIFont, fontColor: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor
        ]
        let title = NSAttributedString(string: title, attributes: attributes)
        self.setAttributedTitle(title, for: .normal)
    }

    func set(activeColor: UIColor, inactiveColor: UIColor) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.backgroundColor = isActive ? activeColor : inactiveColor
    }

    func set(tabHeight: CGFloat) {
        self.tabHeight = tabHeight
    }

    func set(tagNumber: Int) {
        self.tag = tagNumber
        self.closeButton.tag = tagNumber
    }

}
