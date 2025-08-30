//
//  DIContainer.swift
//  Headliner
//
//  Created by Soop on 8/21/25.
//

import Foundation
import SwiftData

//@MainActor
//@Observable
class DIContainer: ObservableObject {
    var managers: ManagerType
    var pathModel: PathModel
    var modelContext: ModelContext?
    
    @Published var activeTab : TabItem = .main
    
    init(
        managers: ManagerType,
        pathModel: PathModel = PathModel()
    ) {
        self.managers = managers
        self.pathModel = pathModel
 
        self.pathModel.setObjectWillChange(objectWillChange)
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
}

