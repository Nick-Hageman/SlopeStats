//
//  PersistenceController.swift
//  SlopeStats
//
//  Created by Alex Hageman on 12/24/24.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "SlopeStats")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading CoreData: \(error)")
            }
        }
    }
}
