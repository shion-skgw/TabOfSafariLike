//
//  AppDelegate.swift
//  TabOfSafariLike
//
//  Created by Shion on 2020/09/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    weak var viewController: ViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootViewController = ViewController()
        rootViewController.view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        return true
    }

}

class ViewController: UIViewController {

    weak var addButton: UIButton!
    weak var tabController: MutableTabController!

    override func viewDidLoad() {
//        print("\(type(of: self)): \(#function) start")

        super.viewDidLoad()

        let tabController = MutableTabController()
        tabController.view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        addChild(tabController)
        view.addSubview(tabController.view)
        tabController.didMove(toParent: self)
        self.tabController = tabController

        let addButton = UIButton(type: .roundedRect)
        addButton.backgroundColor = .blue
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(adda), for: .touchUpInside)
        view.addSubview(addButton)
        self.addButton = addButton

//        print("\(type(of: self)): \(#function) end")
    }

    override func viewDidLayoutSubviews() {
//        print("\(type(of: self)): \(#function) start")

        super.viewDidLayoutSubviews()

        tabController.view.frame = view.safeAreaLayoutGuide.layoutFrame
        tabController.view.frame.size.height -= 50
        addButton.frame = CGRect(x: 10, y: view.frame.height - 40, width: 50, height: 30)

//        print("\(type(of: self)): \(#function) end")
    }

    var num = 1
    @objc func adda() {
        let tv = UITextView(frame: CGRect(x: 5, y: num * 2, width: 200, height: 100))
        tv.text = "\(num)"
        let vc = UIViewController()
        vc.view = tv
        tabController.addTeb(title: String(format: "TAB_%d", num), viewController: vc)
        num += 1
    }

}
