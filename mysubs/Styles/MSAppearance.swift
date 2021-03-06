//
//  MSAppearance.swift
//  mysubs
//
//  Created by Manon Russo on 09/12/2021.
//

import UIKit

enum MSAppearance {
    static func setUp() {
//        UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 0.1325160861, green: 0.1609178782, blue: 0.1995640397, alpha: 1)
        UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().scrollEdgeAppearance?.backgroundColor = #colorLiteral(red: 0.1325160861, green: 0.1609178782, blue: 0.1995640397, alpha: 1)
        UINavigationBar.appearance().standardAppearance.backgroundColor = #colorLiteral(red: 0.1325160861, green: 0.1609178782, blue: 0.1995640397, alpha: 1)
    }
}
