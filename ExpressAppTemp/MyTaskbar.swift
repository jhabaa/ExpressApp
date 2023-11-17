//
//  MyTaskbar.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 15/11/2023.
//

import SwiftUI
enum TabBarPages:Hashable{
    case home, cart, account
}

struct MyTaskbar: View {
    @State var currentPage:TabBarPages = .home
    var body: some View {
        ZStack(alignment: .bottom, content: {
            TabView(selection: $currentPage,
                    content:  {
                Text("Home").tabItem { Text("\(currentPage == .home ? "Home" : "autre")") }.tag(TabBarPages.home)
                Text("Cart").tabItem { Text("Cart") }
                    .tag(TabBarPages.cart)
            })
            .tabViewStyle(.page(indexDisplayMode: PageTabViewStyle.IndexDisplayMode.never))
            #warning("Continue here")
        })
        
        
    }
}

#Preview {
    MyTaskbar()
}
