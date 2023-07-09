//
//  ExpressLogo.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 25/10/2023.
//

import SwiftUI

struct ExpressLogo: View {
    @State var animated:Bool = true
    var body: some View {
        ZStack(alignment:.center) {
            #warning("To do")
            //up
            Path{path in
                //path.move(to: CGPoint.init(x: 0, y: 0))
                path.addArc(center: .init(x: 150, y: 110), radius: 100, startAngle: Angle(degrees: -15), endAngle: Angle(degrees: 195), clockwise: true)
            }
            .stroke(.blue, lineWidth: 5)
            .scaleEffect(animated ? 1 : 1.8, anchor: .center)
            .animation(.spring().repeatForever(), value: animated)
            VStack{
                Text("EX-PRESS")
                    .font(.custom("Gotham-Bold", size: 45))
                HStack{
                    Text("ECO")
                        .foregroundStyle(.green)
                    Text("DRY CLEAN")
                }
                .font(.custom("Ubuntu", size: 20))
                Text("since 1997")
                    .font(.custom("Ubuntu", size: 10))
            }
            .offset(y:-20)
            Path{path in
                //path.move(to: CGPoint.init(x: 0, y: 0))
                path.addArc(center: .init(x: 150, y: 110), radius: 100, startAngle: Angle(degrees: 15), endAngle: Angle(degrees: -195), clockwise: false)
            }
            .stroke(.blue, lineWidth: 5)
        }
        .frame(width:300, height:300,alignment: .center)
        //little circle
        .overlay(alignment: .bottomTrailing) {
            Path{path in
                //path.move(to: CGPoint.init(x: 0, y: 0))
                path.addArc(center: .init(x: 200, y: 190), radius: 20, startAngle: Angle(degrees: -10), endAngle: Angle(degrees: -230), clockwise: false)
            }
            .stroke(lineWidth: 2)
            Path{path in
                //path.move(to: CGPoint.init(x: 0, y: 0))
                path.addArc(center: .init(x: 200, y: 190), radius: 20, startAngle: Angle(degrees: -30), endAngle: Angle(degrees: -210), clockwise: true)
            }
            .stroke(lineWidth: 2)
        }
        
    }
}

#Preview {
    ExpressLogo()
}
