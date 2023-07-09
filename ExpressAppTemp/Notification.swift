//
//  Notification.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 15/04/2022.
//

import SwiftUI

//Struct Notification
struct Alert:Hashable{
    var color:Color
    var text:String
    init(color: Color, text: String) {
        self.color = color
        self.text = text
    }
    
    var isEmpty:Bool{
        return self.text == String()
    }
}

final class Alerte:ObservableObject{
    @Published var this:Alert = Alert(color: Color("xpress"), text: String())
    var null:Alert = Alert(color: Color("xpress"), text: String())
}

struct Notification: View {
    //@State var _notificationText:String
    @EnvironmentObject var alerte:Alerte
    var body: some View {
        GeometryReader {
            let size = $0.size
            
                VStack{
                    Text(alerte.this.text).bold().padding()
                        .font(.custom("Outfit", size: 20))
                        .background{
                            RoundedRectangle(cornerRadius: 20).fill(Color("xpress"))
                                .opacity(0.7)
                                .shadow(radius: 3)
                        }
                }
                //.scaleEffect(alerte.this.text.isEmpty ? 0 : 1)
                //.animation(.loading(), value: alerte.this.text)
                .offset(y: alerte.this.isEmpty ? -150 : 0)
                .transition(.scale)
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear(perform: {
                    //alerte.this.text = "test"
                    withAnimation(.loading()){
                        
                        alerte.this.text = String()
                    }
                })
        }.frame(alignment: .top)
    }
}

struct Previews_Notification_Previews: PreviewProvider {
    static var previews: some View {
        Notification()
            .environmentObject(Alerte())
    }
}
