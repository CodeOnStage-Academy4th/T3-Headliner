//
//  ShazamManager.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import ShazamKit

protocol ShazamManagerType {
    
}

final class ShazamManager: ShazamManagerType {
    private let shManagedSession = SHManagedSession()
}

extension ShazamManager {
    func prepare() async {
        await shManagedSession.prepare()
    }
}
