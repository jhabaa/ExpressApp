//
//  Header.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 24/02/2023.
//

import SwiftUI

//A supprimer

struct Header: View {
    @EnvironmentObject var userdata:UserData
    var body: some View {
    GeometryReader { proxy in
        List{
            //panier check
            ForEach(userdata.command_checker.sorted(by: {$0.key < $1.key}), id: \.key) { c,v in
                
                VStack{
                    Text(c)
                }
                
            }
            
        }
            /*
            HStack(alignment:.top) {
                if userdata.currentPage.PageLevel == 0{
                    //User settings ???
                    Image(systemName: "gearshape")
                        .padding(10)
                        .badge(userdata.cart.isEmpty ? 1: 0)
                        .background{
                            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: RoundedCornerStyle.circular).fill(.bar)
                        }
                        .shadow(radius: 2)
                        .scaleEffect(1)
                        .scaledToFit()
                        .background(.bar)
                        .cornerRadius(20)
                        .onTapGesture {
                            Task{
                                withAnimation(.spring()){
                                    //showPage = false
                                    userdata.GoToPage(goto: "reglages")
                                    print("Go to settings")
                                }
                            }
                            
                        }
                }else{
                    Image(systemName: "chevron.backward")
                        .padding(10)
                        .background{
                            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: RoundedCornerStyle.circular).fill(.thickMaterial)
                                
                        }
                        .shadow(radius: 2)
                        .scaleEffect(1)
                        .scaledToFit()
                        .background(.bar)
                        .cornerRadius(20)
                        .onTapGesture {
                            withAnimation(.spring()){
                                //showPage = false
                                if userdata.currentPage.PageName=="accueil"{
                                    userdata.LevelDown()
                                }else{
                                    userdata.Back()
                                }
                               
                            }
                            
                        }
                }
                
                Spacer()
                HStack(){
                    if !userdata.cart.isEmpty{
                        HStack(spacing:5){
                            Text("\(userdata.cart.count)")
                                .font(.caption).bold()
                                .padding(.horizontal, 10)
                            Text("Elements")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        
                    }
                    Image(systemName: "cart")
                        .padding(10)
                        .badge(userdata.cart.isEmpty ? 1: 0)
                        .background{
                            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: RoundedCornerStyle.circular).fill(.bar)
                            
                            
                            
                        }
                        .shadow(radius: 2)
                        .scaleEffect(1)
                        .scaledToFit()
                }
                .background(.bar)
                .cornerRadius(20)
                .onTapGesture {
                    withAnimation(.easeInOut){
                        userdata.GoToPage(goto: "panier")
                    }
                    
                }
                
                    
            }
            .padding(.horizontal, 30)
            
            */
        }
        .zIndex(100)
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        Header().environmentObject(userData)
    }
}
