//
//  Persistence.swift
//  Shared
//
//  Created by Muhannad Qaisi on 5/20/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<1 {
            let newItem2 = MTIncome(context: viewContext)
            newItem2.amount =  NSDecimalNumber(0)
            newItem2.name = "Income Item"
            let newItem3 = MTSavings(context: viewContext)
            newItem3.amount =  NSDecimalNumber(0)
            newItem3.name = "Emergency Fund"
            let newItem33 = MTSavings(context: viewContext)
            newItem33.amount =  NSDecimalNumber(0)
            newItem33.name = "Other Savings"
            let newItem4 = MTHousing(context: viewContext)
            newItem4.amount =  NSDecimalNumber(0)
            newItem4.name = "Mortgage/Rent"
            let newItem41 = MTHousing(context: viewContext)
            newItem41.amount =  NSDecimalNumber(0)
            newItem41.name = "Gas"
            let newItem42 = MTHousing(context: viewContext)
            newItem42.amount =  NSDecimalNumber(0)
            newItem42.name = "Water"
            let newItem43 = MTHousing(context: viewContext)
            newItem43.amount =  NSDecimalNumber(0)
            newItem43.name = "Internet"
            let newItem44 = MTHousing(context: viewContext)
            newItem44.amount =  NSDecimalNumber(0)
            newItem44.name = "Trash"
            let newItem5 = MTTransportation(context: viewContext)
            newItem5.amount =  NSDecimalNumber(0)
            newItem5.name = "Gas"
            let newItem52 = MTTransportation(context: viewContext)
            newItem52.amount =  NSDecimalNumber(0)
            newItem52.name = "Maintenance"
            let newItem6 = MTFood(context: viewContext)
            newItem6.amount =  NSDecimalNumber(0)
            newItem6.name = "Grocories"
            let newItem62 = MTFood(context: viewContext)
            newItem62.amount =  NSDecimalNumber(0)
            newItem62.name = "Restaurants"
            let newItem7 = MTPersonal(context: viewContext)
            newItem7.amount =  NSDecimalNumber(0)
            newItem7.name = "Clothing"
            let newItem71 = MTPersonal(context: viewContext)
            newItem71.amount =  NSDecimalNumber(0)
            newItem71.name = "Entertainemnt"
            let newItem72 = MTPersonal(context: viewContext)
            newItem72.amount =  NSDecimalNumber(0)
            newItem72.name = "Cosmetics/Hair"
            let newItem81 = MTInsurance(context: viewContext)
            newItem81.amount =  NSDecimalNumber(0)
            newItem81.name = "Health Insurance"
            let newItem82 = MTInsurance(context: viewContext)
            newItem82.amount =  NSDecimalNumber(0)
            newItem82.name = "Car Insurance"
            let newItem91 = MTMembership(context: viewContext)
            newItem91.amount =  NSDecimalNumber(0)
            newItem91.name = "Music Membership"
            let newItem92 = MTMembership(context: viewContext)
            newItem92.amount =  NSDecimalNumber(0)
            newItem92.name = "Gym Membership"

        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MoneyTracker")
        guard let description = container.persistentStoreDescriptions.first else {
              fatalError("###\(#function): Failed to retrieve a persistent store description.")
            }
            if inMemory {
              description.url = URL(fileURLWithPath: "/dev/null")
            } else {
              // Enable remote notifications
              description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
              description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

    }
    
    private func deleteAll(entityName: String) {
        
        
        let context = container.viewContext
        
        do {
            let fetch =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)

            request.resultType = .resultTypeObjectIDs

            let result = try context.execute(request) as? NSBatchDeleteResult
            let objIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objIDArray]

            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    private func updateAll(entityName: String){
        let context = container.viewContext
        do {
            let request = NSBatchUpdateRequest(entityName: entityName)
            request.resultType = .updatedObjectIDsResultType
            request.propertiesToUpdate = ["amount": 0.00]

            let result = try context.execute(request) as? NSBatchUpdateResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSUpdatedObjectsKey: objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func reset() {
        
        let names = container.managedObjectModel.entities.map({ (entity) -> String in
            return entity.name!
        })

        
        names.forEach { cur in
            self.deleteAll(entityName: cur)
        }
        names.forEach { cur in
            self.updateAll(entityName: cur)
        }
        
    }
}
