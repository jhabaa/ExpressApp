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
                    ExpressLogo()
                        .scaleEffect(onAnimation ? 1 : 1.1)
                        .animation(.loading(), value: onAnimation)

                }.frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height)
            }.frame(maxWidth: GeometryProxy.size.width, alignment: Alignment.center)
                .background(Color("xpress").opacity(0.1).gradient)
            .background()
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
