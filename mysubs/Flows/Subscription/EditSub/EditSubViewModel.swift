//
//  EditSubViewModel.swift
//  mysubs
//
//  Created by Manon Russo on 13/12/2021.
//

import Foundation

final class EditSubViewModel: NSObject {
    // Private properties
    private let coordinator: AppCoordinatorProtocol
    private let storageService: StorageServiceProtocol
    private var notificationService = NotificationService()
    private var subscription: Subscription
    private var isDateChanged: Bool {
        date != subscription.commitment
    }
    
    // Public properties
    weak var viewDelegate: EditSubController?
    var notificationDate: Date?
    var icon: Data?
    var recurrency: String?
    var reminder: String?
    var color: String?
    var name: String?
    var price: Float?
    var date: Date?
    var reminderValue: Int?
    var reminderType: Calendar.Component?
    var recurrencyValue: Int?
    var recurrencyType: Calendar.Component = .hour
    
    init(coordinator: AppCoordinatorProtocol, storageService: StorageServiceProtocol, subscription: Subscription) {
        self.coordinator = coordinator
        self.storageService = storageService
        self.subscription = subscription
        self.price = subscription.price
        self.name = subscription.name
        self.color = subscription.color
        self.reminder = subscription.reminder
        self.date = subscription.commitment
        self.recurrency = subscription.paymentRecurrency
        self.icon = subscription.icon
    }
    
    // Methods
    func delete() {
        do {
            try storageService.delete(subscription)
            let id = subscription.objectID.uriRepresentation().absoluteString
            notificationService.cancelnotif(for: id)
        } catch { print("can't delete sub because of error", error, "\n", error.localizedDescription) }
    }
    
    func save() {
        storageService.save()
    }
    
    func goBack() {
        coordinator.goBack()
    }
    
    func saveEditedSub() {
        //Minimum values to save a sub
        subscription.name = name
        subscription.price = price ?? 0
        
        //Color & icon
        subscription.icon = icon
        subscription.color = color
        
        //But if the date has value changed (mean notif has been recalculated) then both next values has to be saved, then generating a notif with it
        let id = subscription.objectID.uriRepresentation().absoluteString
        if isDateChanged {
            if date == nil {
                notificationService.cancelnotif(for: id)
            } else {
                //If date is changed, all other parameters are reset in dateDidChange in VC
                subscription.commitment = date
                if let reminderValue = reminderValue, let recurrencyValue = recurrencyValue, let reminderType = reminderType, let price = price, let date = date, let name = name {
                    subscription.reminder = "\(reminderValue) \(reminderType.stringValue)"
                    subscription.paymentRecurrency = "\(recurrencyValue) \(recurrencyType.stringValue)"
                    self.notificationDate = date.adding(reminderType, value: -(reminderValue))
                    self.notificationDate = self.notificationDate?.adding(recurrencyType, value: recurrencyValue)
                    print("self.notification date in newsubVM is : \(self.notificationDate!)")
                    notificationService.generateNotificationFor(name, reminderValue, price, self.notificationDate ?? Date(), id: id, reminderType: reminderType)
                }
            }
        }
        storageService.save()
        goBack()
    }
}
