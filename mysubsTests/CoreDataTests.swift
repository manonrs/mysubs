//
//  CoreDataTests.swift
//  mysubsTests
//
//  Created by Manon Russo on 25/01/2022.
//

import CoreData
import XCTest
@testable import mysubs

final class CoreDataTests: XCTestCase {
//
    var storageService: StorageService!
    var loadedSubscriptions: [Subscription] = []
    var sub1 = Subscription()
    var sub2 = Subscription()

    override func setUp() {
        super.setUp()
        // MARK: - managedObjectModel
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!

        // MARK: - persistentStoreDescription
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        persistentStoreDescription.shouldAddStoreAsynchronously = true

        // MARK: - persistentContainer
        let persistentContainer = NSPersistentContainer(name: "mysubs", managedObjectModel: managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
        persistentContainer.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType, "Store description is not of type NSInMemoryStoreType")
            if let error = error as NSError? {
                fatalError("Persistent container creation failed : \(error.userInfo)")
            }
        }
        storageService = StorageService(persistentContainer: persistentContainer)
        sub1 = Subscription(context: storageService.viewContext)
        sub2 = Subscription(context: storageService.viewContext)
        loadedSubscriptions = [sub1, sub2]
    }

    override func tearDown() {
        super.tearDown()
        storageService = nil
        loadedSubscriptions = []
    }
    
    func testSubLoading() throws {
        storageService.save()
        do {
            loadedSubscriptions = try storageService.loadsubs()

        } catch {
            XCTFail("error loading \(error.localizedDescription)")
        }
        XCTAssertFalse(loadedSubscriptions.isEmpty)
        XCTAssertTrue(loadedSubscriptions.count == 2)

    }
    
    func testSubLoadingAndDeletion() throws {
        storageService.save()
        do {
            loadedSubscriptions = try storageService.loadsubs()

        } catch {
            XCTFail("error loading \(error.localizedDescription)")
        }
        
        for sub in loadedSubscriptions {
            do {
                try storageService.delete(sub)
            } catch {
                XCTFail("error deleting \(error.localizedDescription)")
            }
            
            do {
                loadedSubscriptions = try storageService.loadsubs()
                
            } catch {
                XCTFail("error loading \(error.localizedDescription)")
            }
        }
        XCTAssertTrue(loadedSubscriptions.isEmpty)
        XCTAssertTrue(loadedSubscriptions.count == 0)
    }

}
