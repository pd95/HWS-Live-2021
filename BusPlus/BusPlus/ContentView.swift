//
//  ContentView.swift
//  BusPlus
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userData = UserData()

    var body: some View {
        TabView {
            BusListView()
                .tabItem {
                    BusListView.label
                }

            TicketView()
                .tabItem {
                    TicketView.label
                }
                .badge(userData.isValid == false ? "!" : nil)
        }
        .environmentObject(userData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
