//
//  SceneDelegate.swift
//  HiTrending_Example
//
//  Created by 杨建祥 on 2026/4/9.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController.init(rootViewController: ViewController())
        self.window = window
        window.makeKeyAndVisible()
    }
}
