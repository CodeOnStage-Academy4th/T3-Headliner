//
//  DIContainer.swift
//  Headliner
//
//  Created by Soop on 8/21/25.
//

import Foundation

//@MainActor
//@Observable
class DIContainer: ObservableObject {
    var managers: ManagerType
    var pathModel: PathModel
    
    init(
        managers: ManagerType,
        pathModel: PathModel = PathModel()
    ) {
        self.managers = managers
        self.pathModel = pathModel
 
        self.pathModel.setObjectWillChange(objectWillChange)
    }
}

