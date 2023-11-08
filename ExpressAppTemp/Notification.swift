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
    @Published var type:notificationStyle = .none
    @Published var value:String = String()
    @Published var icon:UIImage?
    
    func NewNotification(_ type:notificationStyle, _ value:String, _ icon:UIImage?){
        self.type = type
        self.value = value
        self.icon = icon
    }
    func EraseNotification(){
        self.type = .none
        self.value = ""
        self.icon = nil
    }
}
/*
struct Notification: View {
    //@State var _notificationText:String
    @EnvironmentObject var alerte:Alerte
    var body: some View {
        GeometryReader {
            let size = $0.size
            
                VStack{
                    Text(alerte.this.text).bold().padding()
                        .font(.custom("Outfit", size: 20))
                        .frame(maxWidth: .infinity)
                        .background{
                            RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                .shadow(radius: 3)
                        }
                }
                
                //.scaleEffect(alerte.this.text.isEmpty ? 0 : 1)
                //.animation(.loading(), value: alerte.this.text)
                //.offset(y:alerte.this.isEmpty ? -200 : 0)
                //.scaleEffect(alerte.this.isEmpty ? 0 : 1, anchor:.top)
                .transition(.scale)
                .frame(height: 200)
                .background(.red)
                
                .animation(.spring(), value: alerte.this.isEmpty)
                .onAppear(perform: {
                    //alerte.this.text = "test"
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)){
                        alerte.this.text = ""
                    }
                })
        }.frame(alignment: .top)
    }
}

struct Previews_Notification_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserData())
                .environmentObject(FetchModels())
                .environmentObject(AppSettings())
                .environmentObject(Panier())
                .environmentObject(Article())
                .environmentObject(Utilisateur())
                .environmentObject(Alerte())
                .environmentObject(Days())
    }
}
*/
