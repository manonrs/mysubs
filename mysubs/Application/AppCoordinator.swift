//
//  AppCoordinator.swift
//  mysubs
//
//  Created by Manon Russo on 06/12/2021.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator, AppCoordinatorProtocol {
    var navigationController: UINavigationController
     
    private let storageService: StorageService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.storageService = StorageService()
    }

    func start() {
        print("ok")
        showSubScreen()
    }
    
    func showSubScreen() {
        let homeVC = HomeViewController()
        let homeVCViewModel = HomeViewModel(coordinator: self, storageService: storageService)
        homeVCViewModel.viewDelegate = homeVC
        homeVC.viewModel = homeVCViewModel
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    func showNewSubScreenFor() {
        let newSubVC = NewSubController()
        let newSubVCViewModel = NewSubViewModel(coordinator: self, storageService: storageService)
        newSubVCViewModel.viewDelegate = newSubVC
        newSubVC.viewModel = newSubVCViewModel
        navigationController.pushViewController(newSubVC, animated: true)
    }
    
    func showDetailSubScreen(sub: Subscription) {
        let editSubVC = EditSubController()
        let editSubViewModel = EditSubViewModel(coordinator: self, storageService: storageService, subscription: sub)
        editSubViewModel.viewDelegate = editSubVC
        editSubVC.viewModel = editSubViewModel
        navigationController.pushViewController(editSubVC, animated: true)
    }
     
    func goBack() {
        navigationController.popToRootViewController(animated: true)
    }
}

protocol AppCoordinatorProtocol: Coordinator {
    
    func start()
    
    func showSubScreen()
    
    func showNewSubScreenFor()
    
    func showDetailSubScreen(sub: Subscription)
     
    func goBack()
    
}
