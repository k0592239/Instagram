//
//  TabBarControllerViewController.swift
//  Instagram
//
//  Created by 佐藤佳子 on 2023/01/13.
//

import UIKit

class TabBarControllerViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // タブバーの背景色を変更
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する
        self.delegate = self
    }
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController {
            // ImageSelectViewControllerは、タブ切り替えではなくモーダル画面遷移する
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect")
            present(imageSelectViewController, animated: true)
            return false
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
    }
}
