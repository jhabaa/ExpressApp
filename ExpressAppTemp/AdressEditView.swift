//
//  AdressEditView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 15/05/2023.
//

import SwiftUI

struct AdressEditView: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var commande:Commande
    @StateObject var focusState = focusObjects()
    @State var is_valid:Bool=false
    @State var street:String=String()
    @State var number:String=String()
    @State var sup:String=String()
    @State var postal:String=String()
    @State var city:String=String()
    @Binding var _show:Bool
    var body: some View {
        GeometryReader {
            let size = $0.size
            //back button
            VStack{
                Button("Annuler") {
                    withAnimation(.spring()){
                        _show.toggle()
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .frame(width:size.width, height: 40, alignment:.leading)
            .background(.bar)
            
            ScrollView{
                    Text("Changement d'adresse")
                    .font(.headline)
                CustomTextField(_text: $street, _element: "rue", type: .text)
                HStack{
                    CustomTextField(_text: $number, _element: "numero", type: .text)
                    CustomTextField(_text: $sup, _element: "supplement", type: .text)
                }
                    
                CustomTextField(_text: $postal, _element: "code postal", type: .text)
                CustomTextField(_text: $city, _element: "ville", type: .text)
                    
                   //if adress is correct 
                if is_valid{
                    Button("Enregistrer") {
                        commande.this.infos = "Adresse de récupération \([street, number, sup, postal, city].joined(separator: " "))"
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .padding(.top, 100)
                }
            }
            .clipped()
            .onTapGesture {
                //return all to false first
                withAnimation(.spring()){
                    focusState.focus_in.forEach { (key: String, value: Bool) in
                        focusState.focus_in.updateValue(false, forKey: key)
                    }
                }
            }
            .padding(.top, 50)
                //.onAppear{is_valid =  userdata.currentUser.readAdress(_adress)}
        }
        .onChange(of: [street, number, sup, postal, city] , perform: { value in
            is_valid = utilisateur.this.readAdress([street, number, sup, postal, city])
        })

        .onAppear(perform: {
            (street, number, sup, postal, city) = utilisateur.this.get_adress_datas()
        })
        .background(.bar)
        .environmentObject(focusState)
    }
}

struct AdressEditView_Previews: PreviewProvider {
    static var previews: some View {
        AdressEditView(_show: .constant(true)).environmentObject(UserData())
            .environmentObject(Commande())
    }
}
