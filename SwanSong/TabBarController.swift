//
//  TabBarController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        guard let order = UserDefaults.standard.value(forKey: "globalControllerOrder") as? [Int] else { return }
        
        var reordered = [UIViewController]()
        if let items = viewControllers {
            for tag in order {
                for item in items {
                    if item.tabBarItem.tag == tag {
                        reordered.append(item)
                    }
                }
            }
        }
        setViewControllers(reordered, animated: false)
    }
    
    override func tabBar(_ tabBar: UITabBar, didEndCustomizing items: [UITabBarItem], changed: Bool) {
        var order = [Int]()
        
        if let items = viewControllers {
            for item in items {
                order.append(item.tabBarItem.tag)
            }
        }
        
        UserDefaults.standard.set(order, forKey: "globalControllerOrder")
    }
    
}
