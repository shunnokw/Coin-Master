//
//  AppDelegate.swift
//  Wheelsales
//
//  Created by Jason Wong on 11/2/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        let tabController = UITabBarController()
        
        let cs = CoinService()
        
        let tab1Nav = UINavigationController(rootViewController: HomeViewController(viewModel: CoinListViewModel(coinService: cs)))
        let tab2Nav = UINavigationController(rootViewController: BookmarkPageViewController(viewModel: BookmarkPageViewModel(coinService: cs, userDefaults: UserDefaults.standard)))
        let tab3Nav = UINavigationController(rootViewController: MyCoinPageViewController(viewModel: MyCoinPageViewModel(coinService: cs)))
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .purple
            tab1Nav.navigationBar.standardAppearance = barAppearance
            tab1Nav.navigationBar.scrollEdgeAppearance = barAppearance
            
            tab2Nav.navigationBar.standardAppearance = barAppearance
            tab2Nav.navigationBar.scrollEdgeAppearance = barAppearance
            
            tab3Nav.navigationBar.standardAppearance = barAppearance
            tab3Nav.navigationBar.scrollEdgeAppearance = barAppearance
        } else {
            tab1Nav.navigationBar.barTintColor = .purple
            tab2Nav.navigationBar.barTintColor = .purple
            tab3Nav.navigationBar.barTintColor = .purple
        }
        
        tabController.viewControllers = [
            tab1Nav,
            tab2Nav,
            tab3Nav
        ]
        
        tabController.tabBar.items![0].title = "Coin List"
        tabController.tabBar.items![0].image = UIImage.fontAwesomeIcon(name: .coins, style: .solid, textColor: .black, size: CGSize(width: 20, height: 20))
        
        tabController.tabBar.items![1].title = "Bookmark"
        tabController.tabBar.items![1].image = UIImage.fontAwesomeIcon(name: .book, style: .solid, textColor: .black, size: CGSize(width: 20, height: 20))
        
        tabController.tabBar.items![2].title = "My Coins"
        tabController.tabBar.items![2].image = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .black, size: CGSize(width: 20, height: 20))
        
        window?.rootViewController = tabController
        
        return true
    }
}

