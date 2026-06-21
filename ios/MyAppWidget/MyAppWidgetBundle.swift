//
//  MyAppWidgetBundle.swift
//  MyAppWidget
//
//  Created by Febry Ardiansyah on 21/06/26.
//

import WidgetKit
import SwiftUI

@main
struct MyAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        MyAppWidget()
        MyAppWidgetControl()
        MyAppWidgetLiveActivity()
    }
}
