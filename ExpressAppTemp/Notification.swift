//
//  Notification.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 15/04/2022.
//

import SwiftUI

struct Notification: View {
    //@State var _notificationText:String
    @EnvironmentObject var userdata : UserData
    @State var _show:Bool = true
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            if _show{
                VStack{
                    Text(userdata.notification).bold().padding()
                        .font(.custom("Outfit", size: 20))
                        .background{
                            RoundedRectangle(cornerRadius: 20).fill(Color("xpress"))
                                .opacity(0.7)
                                .shadow(radius: 3)
                        }
                }
                .scaleEffect(userdata.notification.isEmpty ? 0 : 1)
                .animation(.loading(), value: userdata.notification)
                .transition(.scale)
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear(perform: {
                    withAnimation(.loading()){
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2){
                            _show = false
                            //userdata.notification = String()
                        }
                    }
                })
            }
        }.frame(alignment: .top)
        //On change on notifiaction text, this view will show
            .onChange(of: userdata.notification) { _ in
                withAnimation(.spring()) {
                    _show = true
                }
            }
    }
}

struct Previews_Notification_Previews: PreviewProvider {
    static var previews: some View {
        Notification()
    }
}
