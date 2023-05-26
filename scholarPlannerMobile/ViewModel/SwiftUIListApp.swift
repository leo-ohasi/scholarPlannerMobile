//
//  SwiftUIListApp.swift
//  scholarPlannerMobile
//
//  Created by Leonardo Ohasi on 25/05/23.
//

import SwiftUI

@main
struct SwiftUIListApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView().environmentObject(TodoListViewModel())
        }
    }
}

