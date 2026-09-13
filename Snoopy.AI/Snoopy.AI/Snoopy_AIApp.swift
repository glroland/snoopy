//
//  Snoopy_AIApp.swift
//  Snoopy.AI
//
//  Created by Lee Roland on 9/8/26.
//

import SwiftUI

@main
struct Snoopy_AIApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
        }
    }
}
