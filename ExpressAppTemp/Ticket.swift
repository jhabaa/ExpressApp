//
//  Ticket.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 08/04/2022.
//

import SwiftUI
import CoreGraphics
struct TicketParameters{
    struct Segment{
        let line:CGPoint
        //let curve:CGPoint
        //let control:CGPoint
    }
    
    static let segments = [
        Segment(line: CGPoint(x: 1, y: 2)),
        
        Segment(line: CGPoint(x: 3, y: 4))
    ]
}
struct Ticket: View {
    
    var body: some View {
        GeometryReader { GeometryProxy in
            VStack{
                //Header
                
                
                //Cards
                ScrollView {
                        ZStack{
                            Rectangle().fill(.radialGradient(Gradient.init(colors: [.blue,.clear]), center: .bottomLeading, startRadius: 0, endRadius: 100))
                            VStack{
                                Text("Numero de Commande")
                                    .bold()
                                Divider()
                                Text("Articles").padding(.horizontal).background().clipShape(Capsule()).shadow(radius: 3)
                                ScrollView(Axis.Set.horizontal){
                                    HStack{
                                        Text("Chemise")
                                        Text("Chemise")
                                        Text("Chemise")
                                    }
                                    
                                }
                                Text("Cout Total").padding(.horizontal).background().clipShape(Capsule()).shadow(radius: 3)
                                    .padding()
                                Text("Message").padding(.horizontal).background().clipShape(Capsule()).shadow(radius: 3)
                                Spacer()
                                HStack{
                                    Text("Status : ")
                                }.padding()
                                
                            }
                            
                        }.frame(width: GeometryProxy.size.width - 30, height: GeometryProxy.size.height/2, alignment: .center).background(.thickMaterial).cornerRadius(20).shadow(radius: 9)
                }
                .padding(.top)
                    
                
                Spacer()
            }
        }
        
    }
}

struct Ticket_Previews: PreviewProvider {
    static var previews: some View {
        Ticket()
    }
}
