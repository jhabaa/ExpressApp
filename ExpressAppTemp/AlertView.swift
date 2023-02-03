//
//  AlertView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 01/05/2022.
//

import SwiftUI

struct AlertView: View {
    @State var texte:String = ""
    @State var value:Decimal = Decimal.zero
    @State var ACTIVE:Bool = false
    @Binding var showAlert:Bool
    @EnvironmentObject var fetchModel : FetchModels
    @State var emailFieldIsFocused: Bool = false
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack(alignment: Alignment.center) {
                VStack {
                    TextField(text: $texte, prompt: Text.init(LocalizedStringKey.init("NEW COUPON CODE"))) {
                        
                    }.background(.thinMaterial)
                        .font(Font.system(size: 30, weight: .light, design: Font.Design.rounded))
                        .clipShape(Capsule())
                        .padding()
                    
                    TextField(value: $value, format: .currency(code: "EUR"), prompt: Text.init(LocalizedStringKey.init("VALEUR"))) {
                        
                    }
                    .background(.thinMaterial)
                        .font(Font.system(size: 30, weight: .light, design: Font.Design.rounded))
                        .clipShape(Capsule())
                        .padding()
                    
                    //toggle
                        Toggle("Actif", isOn: $ACTIVE)
                            .toggleStyle(.button)
                    
                    //Bouton de validation
                    Divider().padding()
                    HStack{
                        Button {
                            withAnimation(.spring()) {
                                showAlert.toggle()
                            }
                            
                        } label: {
                            Text("Annuler")
                        }.tint(.red)
                        Button("Ajouter"){
                           
                            Task {
                                let coupon:Coupon = Coupon.init()
                                if await fetchModel.PushCoupon(coupon: coupon){
                                    showAlert.toggle()
                                }
                                
                            }
                            
                        }
                        

                    }
                    .buttonStyle(.bordered).font(.title2).buttonBorderShape(.capsule)
                    
                }.frame(width: GeometryProxy.size.width, height: 300, alignment: Alignment.center).background(.thinMaterial)
                    
                   
            }
        }
    }
}

