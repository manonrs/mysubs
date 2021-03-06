//
//  HomeViewModelTests.swift
//  mysubsTests
//
//  Created by Manon Russo on 01/02/2022.
//

import XCTest
@testable import mysubs

class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var mockStorageService: MockStorageService!
    var mockCoordinator: MockCoordinator!
    
    var loadedSubscriptions: [Subscription] = []
    var sub1: Subscription!
    
    override func setUpWithError() throws {
        mockStorageService = MockStorageService()
        mockCoordinator = MockCoordinator()
        viewModel = HomeViewModel(coordinator: mockCoordinator, storageService: mockStorageService)
        
        sub1 = Subscription(context: mockStorageService.viewContext)

    }

    override func tearDownWithError() throws {
        mockStorageService = nil
        mockCoordinator = nil
//        viewModel = nil
    }
    
    func testComputeTotalWithValue() {
        sub1.price = 22
        viewModel.subscriptions = [sub1]
        viewModel.computeTotal()
        XCTAssertEqual(viewModel.totalAmount, "22.0 €")
    }
    
    func testComputeTotalWithoutValue() {
        viewModel.subscriptions = []
        viewModel.computeTotal()
        //dddd
        XCTAssertEqual(viewModel.totalAmount, "")
    }
    
    func testFetchSub() throws {
        XCTAssertFalse(mockStorageService.loadsubsIsCalled)

        viewModel.fetchSubscription()
        XCTAssertTrue(mockStorageService.loadsubsIsCalled)
    }
    
    func testShowNewSub() throws {
        XCTAssertFalse(mockCoordinator.showNewSubScreenForIsCalled)
        viewModel.showNewSub()
        XCTAssertTrue(mockCoordinator.showNewSubScreenForIsCalled)
    }

    func testShowDetailSub() throws {
        XCTAssertFalse(mockCoordinator.showDetailSubScreenIsCalled)
        viewModel.showDetail(sub: sub1)
        XCTAssertEqual(mockCoordinator.subscription, sub1)
        XCTAssertTrue(mockCoordinator.showDetailSubScreenIsCalled)
    }
}
