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
                            .frame(width: value ? 40 : 30)
                            .offset(y:value ? 0 : 10)
                            .minimumScaleFactor(0.3)
                            .overlay(alignment: .center, content: {
                                //If cart is not empty
                                if (!commande.isEmpty && key.PageName=="panier"){
                                    ZStack{
                                        Capsule().fill(Color("xpress"))
                                            .shadow(color: Color("xpress"), radius: 5)
                                        Text("\(commande.getNumberOfArticles)")
                                    }
                                        .offset(y:-10)
                                        .font(.caption)
                                        .scaleEffect(x: !value ? 1 : 0, y: !value ? 1 : 0, anchor:.center)
                                       
                                }
                                
                            })
                        
                        Text("\(key.PageName)")
                            .minimumScaleFactor(0.3)
                            .offset(y:value ? 0 : 20)
                            .scaleEffect(y:value ? 1 : 0 , anchor:.bottom)
                    }
                    .padding(5)
                    .foregroundStyle(value ? .white : .primary)
                    .background{
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color("xpress").gradient)
                            .opacity(value ? 1 : 0)
                            .frame(width: 100)
                    }
                }
                .tint(.primary)

            }
        }
        .frame(height: 80)

        .background(.bar.shadow(.drop(radius: 5)))
        .clipShape(RoundedRectangle(cornerRadius: 20,style:.continuous))
        .padding()
        .scaleEffect(userdata.taskbar ? 1 : 0)
        .animation(.spring, value: userdata.pages)
        .offset(y: userdata.taskbar ? 0 : 100)
        
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
