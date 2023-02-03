//
//  NewCommandView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 30/04/2022.
//

import SwiftUI

struct NewCommandView: View {
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack{
                VStack(alignment:.leading){
                    Text("2020").frame(width: .infinity, alignment: Alignment.leading)
                    Text("SEPTEMBRE").font(.system(size: 40, weight:.bold, design: Font.Design.rounded)).padding(.bottom)
                    let days:[String] = ["3","4","5","6","7"]
                    HStack(spacing:0){
                        ForEach(days, id:\.self){
                            day in
                            Text(day)
                                .fontWeight(.semibold)
                                .frame(maxWidth:.infinity)
                                
                        }
                    }
                    .font(.title)
                    .padding()
                    Spacer()
                }.frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height, alignment: Alignment.leading)
                    
                    VStack{
                        ScrollView{
                            Text("Test")
                            Text("Zone de texte")
                            Spacer()
                        }
                        
                    }.frame(maxWidth: GeometryProxy.size.width).background(.white).clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top,200)
                
                
            }.background(LinearGradient(colors: [.white,.blue,.blue,.blue], startPoint: .top, endPoint: UnitPoint.bottom))
        }
        
    }
}

struct NewCommandView_Previews: PreviewProvider {
    static var previews: some View {
        NewCommandView()
    }
}
