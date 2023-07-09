//
//  TaskView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 03/05/2022.
//

import SwiftUI

struct TaskView: View {
    @State var today:Date = Date.now
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var commande:Commande
    @Environment(\.colorScheme) var colorscheme
    @State var sizeOfPage:CGSize = CGSize.init()
    @Namespace var namespace:Namespace.ID
    var body: some View {
//===================== Taches du jour ==================================
        
        LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]) {
            
            ForEach(userdata.pages.sorted(by: {$0.key.id < $1.key.id}), id: \.key) { key, value in
                
                Button {
                    withAnimation(.interpolatingSpring(mass: 0.1, stiffness: 10, damping: 2, initialVelocity: 0.5)) {
                        userdata.GoToPage(goto: key.PageName)
                       
                    }
                } label: {
                    VStack(spacing:0){
                        Image(systemName: !value ? key.PageIcon : "\(key.PageIcon).fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .offset(y:value ? 0 : 10)
                            .minimumScaleFactor(0.3)
                            .overlay(alignment: .top, content: {
                                //If cart is not empty
                                if (!commande.isEmpty && key.PageName=="panier"){
                                    ZStack{
                                        Circle().fill(Color("xpress"))
                                            .shadow(color: Color("xpress"), radius: 5)
                                        Text("\(commande.getNumberOfArticles)")
                                    }
                                        .offset(y:-30)
                                        .font(.caption)
                                        .scaleEffect(x: !value ? 1 : 0, y: !value ? 1 : 0, anchor:.center)
                                       
                                }
                                
                            })
                        
                        Text("\(key.PageName)")
                            .minimumScaleFactor(0.3)
                            .offset(y:value ? 0 : 20)
                            .scaleEffect(y:value ? 1 : 0 , anchor:.bottom)
                            //.coordinateSpace(name: "imageCart")
                    }
                    .scaleEffect(value ? 1.3 : 1)
                    
                }
                .tint(userdata.activePage.id == key.id ? .blue : .primary)
            }
        }
        .frame(height: 80)
        //.background(colorscheme == .dark ? Color.black.opacity(0.9).shadow(color: .white, radius: 10) : Color.white.opacity(0.9).shadow(color: .black, radius: 10))
        .background(.bar.shadow(.drop(radius: 5)))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .scaleEffect(userdata.taskbar ? 1 : 0)
        .animation(.spring, value: userdata.pages)
        .offset(y: userdata.taskbar ? 0 : 100)
        /*
        HStack{
                
            }
            .frame(height: 70, alignment: Alignment.center)
            .background(.ultraThinMaterial)
            //.background(.thinMaterial)
            .overlay(alignment: userdata.activePage.id == 1 ? Alignment.bottomLeading : userdata.activePage.id == 2 ? .bottom : .bottomTrailing) {
                Rectangle().fill(RadialGradient(colors: [Color("xpress").opacity(1), Color("xpress").opacity(0)], center: .center, startRadius: 0.0, endRadius: 50.0))
                    .shadow(color: Color("xpress"), radius: 10)
                    .frame(width: 120, height: 5,alignment:.center)
                    //.offset(y: value ? 15 : -20)
                    //.scaleEffect(y:value ? 1 : 0, anchor:.top)
            }
            .clipShape(Capsule())
            .coordinateSpace(name: "taskbar")
         */
        }
}

struct Previews_TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
            .environmentObject(FetchModels())
            .environmentObject(UserData())
            .environmentObject(Commande())
    }
}
