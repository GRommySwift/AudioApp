//
//  AudioAppApp.swift
//  AudioApp
//
//  Created by Roman on 06/01/2026.
//

import SwiftUI

@main
struct AudioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 500)
        }
        .defaultSize(width: 600, height: 500)
        .windowStyle(.hiddenTitleBar)
    }
}
