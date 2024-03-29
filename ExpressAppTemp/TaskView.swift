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
    @State var sizeOfPage:CGSize = CGSize.init()
    @Namespace var namespace:Namespace.ID
    var body: some View {
//===================== Taches du jour ==================================

        if (userdata.pages[userdata.GetPage(page: "panier")] == true && !commande.isEmpty){
                HStack{
                    HStack{
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .padding([.vertical],10)
                            .foregroundColor(Color.primary)
                    }
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        //go to home
                        userdata.GoToPage(goto: "accueil")
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            userdata.show_date_selector_view = true
                        }
                    } label: {
                        Text("Continuer")
                            .font(.title)
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(Color("xpress"))
                }
                .padding(-1)
                .clipShape(Capsule())
                .coordinateSpace(name: "taskbar")
                
            }else{
                HStack{
                    ForEach(userdata.pages.sorted(by: {$0.key.id < $1.key.id}), id: \.key) { key, value in
                        HStack{
                            Image(systemName:
                                    !value ? key.PageIcon : "\(key.PageIcon).fill"
                            ).resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .scaleEffect(value ? 1 : 0.7)
                                .padding([.vertical],10)
                                .coordinateSpace(name: "imageCart")
                            if (value){
                                Text("\(key.PageName)")
                                    .font(.title)
                            }
                        }
                        .overlay(alignment: .topTrailing, content: {
                            //If cart is not empty
                            if (!commande.isEmpty && key.PageName=="panier"){
                                Circle()
                                    .fill(.red)
                                    .frame(width: 20)
                            }
                            
                        })
                        .onTapGesture {
                            withAnimation(.interpolatingSpring(mass: 0.1, stiffness: 10, damping: 2, initialVelocity: 0.5)) {
                                userdata.GoToPage(goto: key.PageName)
                                print("Go to  \(key.PageName)")
                            }
                        }
                        .padding([.leading,.trailing])
                        .background(.bar.opacity(userdata.pages[key]! ? 1 : 0))
                        .clipShape(Capsule())
                    }
                }
                .padding(-1)
                .background(userdata.pages[userdata.GetPage(page: "panier")] == true ? Color("xpress").opacity(0.7) : .blue.opacity(0.0))
                .background(.thinMaterial)
                .clipShape(Capsule())
                .coordinateSpace(name: "taskbar")
                .offset(y: userdata.taskbar ? 0 : 100)
            }
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
