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
        super.viewDidLoad()

        let tabContainer = TabView()
        tabContainer.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        tabContainer.container.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        view.addSubview(viewContainer)
        self.viewContainer = viewContainer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var tabContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        tabContainerFrame.size.height = tabHeight
        tabContainer.frame = tabContainerFrame

        var viewContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        viewContainerFrame.origin.y += tabHeight
        viewContainerFrame.size.height -= tabHeight
        viewContainer.frame = viewContainerFrame
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
        let a = CGRect(origin: .zero, size: CGSize(width: 100, height: 28))
        let tabItem = TabItem(frame: a)
        tabItem.set(title: title, font: .systemFont(ofSize: UIFont.systemFontSize), fontColor: .black)
        tabItem.set(active: UIColor(white: 0.5, alpha: 1.0), inactive: UIColor(white: 0.3, alpha: 1.0))
        tabItem.set(tagNumber: tagNumber)
        tabItem.addTarget(self, action: #selector(selectTab(sender:)), for: .touchUpInside)
        tabItem.closeButton.addTarget(self, action: #selector(closeTab(sender:)), for: .touchUpInside)
        tabContainer.add(item: tabItem)

        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == tagNumber })
        viewContainer.subviews.forEach({ $0.isHidden = $0.tag != tagNumber })
    }

}

final class TabView: UIScrollView {

    private(set) weak var container: UIStackView!

    var tabItems: [TabItem] {
        container.subviews.compactMap({ $0 as? TabItem })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialize UIStackView
        let container = UIStackView(frame: .zero)
        container.distribution = .fill
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 0.0
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        self.container = container

        // Layout anchor setting
        self.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true

        // Scroll indicator setting
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(item: TabItem) {
        container.addArrangedSubview(item)
    }

    func remove(item: TabItem) {
        container.removeArrangedSubview(item)
        item.removeFromSuperview()
    }

}

final class TabItem: UIButton {

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

        // Initialize close button
        let closeButton = UIButton(type: .close)
        closeButton.frame.origin.x = (frame.height - closeButton.frame.width) / 2.0
        closeButton.frame.origin.y = (frame.height - closeButton.frame.height) / 2.0
        self.addSubview(closeButton)
        self.closeButton = closeButton

        // Layout title label
        var titleLabelFrame = CGRect.zero
        titleLabelFrame.size.height = frame.height
        titleLabelFrame.size.width = frame.width - frame.height
        titleLabelFrame.origin.x = frame.height
        self.titleLabel?.frame = titleLabelFrame
        self.titleLabel?.textAlignment = .center

        // Design setting
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = 3.0
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func set(tagNumber: Int) {
        self.tag = tagNumber
        self.closeButton.tag = tagNumber
    }

}
