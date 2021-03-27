//
//  SceneDelegate.swift
//  StoreSearch
//
//  Created by Boris Ezhov on 01.03.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  // MARK: - Properties
  var splitVC: UISplitViewController {
    return window!.rootViewController as! UISplitViewController
  }

  var searchVC: SearchViewController {
    let nav = splitVC.viewControllers.first as! UINavigationController
    return nav.viewControllers.first as! SearchViewController
  }

  var detailVC: DetailViewController {
    let nav = splitVC.viewControllers.last as! UINavigationController
    return nav.viewControllers.first as! DetailViewController
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    searchVC.splitViewDetail = detailVC
    splitVC.delegate = self
    if UIDevice.current.userInterfaceIdiom == .phone {
      splitVC.preferredDisplayMode = .oneBesideSecondary
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }

}

// MARK: - Split View Controller Delegate Extension
extension SceneDelegate: UISplitViewControllerDelegate {
  func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    return UIDevice.current.userInterfaceIdiom == .phone ? .primary : proposedTopColumn
  }
}
