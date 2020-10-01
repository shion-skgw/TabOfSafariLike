//
//  MutableTab.swift
//  TabOfSafariLike
//
//  Created by Shion on 2020/09/27.
//

import UIKit

final class MutableTabController: UIViewController {

    private(set) weak var tabContainer: TabView!
    private(set) weak var viewContainer: UIView!

    private(set) var tabHeight: CGFloat = UIFont.systemFontSize * 2

    private var currentTagNumber = 0
    private var nextTagNumber: Int {
        currentTagNumber += 1
        return currentTagNumber
    }

    override func viewDidLoad() {
//        print("\(type(of: self)): \(#function) start")

        super.viewDidLoad()

        let tabContainer = TabView()
        tabContainer.showsVerticalScrollIndicator = false
        tabContainer.showsHorizontalScrollIndicator = false
        tabContainer.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        tabContainer.tabContainer.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        view.addSubview(viewContainer)
        self.viewContainer = viewContainer

//        print("\(type(of: self)): \(#function) end")
    }

    override func viewDidLayoutSubviews() {
//        print("\(type(of: self)): \(#function) start")

        super.viewDidLayoutSubviews()

        tabContainer.frame = CGRect(origin: .zero, size: view.bounds.size)
        tabContainer.frame.size.height = tabHeight

        viewContainer.frame = CGRect(origin: .zero, size: view.bounds.size)
        viewContainer.frame.origin.y += tabHeight
        viewContainer.frame.size.height -= tabHeight

//        print("\(type(of: self)): \(#function) end")
    }

    @objc func selectTab(sender: TabItem) {
        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == sender.tag })
        viewContainer.subviews.forEach({ $0.isHidden = $0.tag != sender.tag })
    }

    @objc func closeTab(sender: UIButton) {
        guard let tabItem = tabContainer.tabItems.filter({ $0.tag == sender.tag }).first,
                let child = children.filter({ $0.view.tag == sender.tag }).first else {
            return
        }

        tabContainer.remove(item: tabItem)
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

        if viewContainer.subviews.filter({ !$0.isHidden }).isEmpty,
                let lastAddView = viewContainer.subviews.max(by: { $0.tag < $1.tag }) {
            lastAddView.isHidden = false
            tabContainer.tabItems.forEach({ $0.isActive = $0.tag == lastAddView.tag })
        }
    }

    func addTeb(title: String, viewController: UIViewController) {
        let tagNumber = nextTagNumber

        // Add child, sub view
        viewController.view.tag = tagNumber
        addChild(viewController)
        viewContainer.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        // Add tab
        let tabItem = TabItem(frame: .zero)
        tabItem.set(title: title, font: .systemFont(ofSize: UIFont.systemFontSize), fontColor: .black)
        tabItem.set(active: UIColor(white: 0.5, alpha: 1.0), inactive: UIColor(white: 0.3, alpha: 1.0))
        tabItem.set(tabHeight: tabHeight)
        tabItem.set(tagNumber: tagNumber)
        tabItem.addTarget(self, action: #selector(selectTab(sender:)), for: .touchUpInside)
        tabItem.closeButton.addTarget(self, action: #selector(closeTab(sender:)), for: .touchUpInside)
        tabContainer.add(item: tabItem)

        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == tagNumber })
        viewContainer.subviews.forEach({ $0.isHidden = $0.tag != tagNumber })
    }

}

final class TabView: UIScrollView {

    private(set) weak var tabContainer: UIStackView!

    var tabItems: [TabItem] {
        tabContainer.subviews.compactMap({ $0 as? TabItem })
    }

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

    private let horizontalMargin: CGFloat = 6
    private var tabHeight: CGFloat = UIFont.systemFontSize * 2
    private var activeColor: UIColor = .white
    private var inactiveColor: UIColor = .white
    private(set) weak var closeButton: UIButton!

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
        self.addSubview(closeButton)
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

    func set(active: UIColor, inactive: UIColor) {
        self.activeColor = active
        self.inactiveColor = inactive
        self.backgroundColor = isActive ? active : inactive
    }

    func set(tabHeight: CGFloat) {
        self.tabHeight = tabHeight
    }

    func set(tagNumber: Int) {
        self.tag = tagNumber
        self.closeButton.tag = tagNumber
    }

}
