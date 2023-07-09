//
//  LoadingView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 06/04/2022.
//

import SwiftUI

struct LoadingView: View {
    @State var onAnimation:Bool = false
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack{
                ZStack{

                    VStack(alignment: HorizontalAlignment.center, content: {
                        Text("EX-PRESS").font(.system(size: 55, weight: .light, design: .rounded))
                            .shadow(color: onAnimation ? .white : .blue, radius: onAnimation ? 50 : 1)
                            .shadow(color: .black, radius: 2, x: 2, y: 2).scaleEffect(onAnimation ? 1 : 1.1)
                            .animation(.loading(), value: onAnimation)
                    }).frame(maxWidth: .infinity,maxHeight: 200)
                        .foregroundColor(.white)
                        .overlay(content: {
                            VStack{
                                HStack{
                                    Text("ECO").foregroundColor(.green).bold()
                                    Text("DRY CLEAN").bold().foregroundColor(.white).shadow(color: .black, radius: 2, x: 2, y: 2)
                                }
                                Text("since 1997").font(.caption2).foregroundColor(.white).shadow(color: .black, radius: 1, x: 1, y: 1)
                            }.offset(x: 0, y: 50)
                                .scaleEffect(onAnimation ? 1 : 1)
                                .animation(.loading(), value: onAnimation)
                        })
                    
                    
                    
                }.frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height)
            }.frame(maxWidth: GeometryProxy.size.width, alignment: Alignment.center)
                .background(Color("xpress").opacity(0.6).gradient)
            .background(.ultraThinMaterial)
            //.transition(.opacity)
        }.onAppear {
            withAnimation {
                onAnimation.toggle()
            }
            
        }
        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
