//
//  AdressEditView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 15/05/2023.
//

import SwiftUI

struct AdressEditView: View {
    @EnvironmentObject var userdata:UserData
    @StateObject var focusState = focusObjects()
    @State var is_valid:Bool=false
    @State var _adress:[String]=["","","","",""]
    @Binding var _show:Bool
    var body: some View {
        GeometryReader {
            _ in
            //back button
            Button("Annuler") {
                withAnimation(.spring()){
                    _show.toggle()
                }
            }
            .padding(.top, 50)
            .padding(.horizontal)
            ScrollView{
                    Text("Changement d'adresse")
                    .font(.headline)
                CustomTextField(_text: $_adress[0], _element: "road", type: .text)
                HStack{
                    CustomTextField(_text: $_adress[1], _element: "number", type: .text)
                    CustomTextField(_text: $_adress[2], _element: "sup", type: .text)
                }
                    
                CustomTextField(_text: $_adress[3], _element: "postal code", type: .text)
                CustomTextField(_text: $_adress[4], _element: "city", type: .text)
                    .onAppear{is_valid =  userdata.currentUser.readAdress(_adress)}
                    
                   //if adress is correct 
                if is_valid{
                    Button("Enregistrer") {
                        userdata.currentCommand.infos = _adress.joined(separator: " ").lowercased().replacingOccurrences(of: "  ", with: " ")
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
            .padding(.top, 100)
            
                //.onAppear{is_valid =  userdata.currentUser.readAdress(_adress)}
        }
        .background(.ultraThinMaterial)
        .environmentObject(focusState)
    }
}

struct AdressEditView_Previews: PreviewProvider {
    static var previews: some View {
        AdressEditView(_show: .constant(true)).environmentObject(UserData())
    }
}
