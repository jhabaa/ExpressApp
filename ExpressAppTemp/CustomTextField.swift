//
//  CustomTextField.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 14/05/2023.
//

import SwiftUI

enum valid_types{
    case text,phone,password
}

struct CustomTextField: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject private var FocusState: focusObjects
    @Environment(\.colorScheme) var colorScheme
    @Binding var _text:String
    @State var _element:String = String()
    @State var hideMode:Bool = true
    @State var type:valid_types
    @State var name:String=String()
    var body: some View {
        ZStack{
            if FocusState.focus_in[_element]! || FocusState.focus_in.allSatisfy({$0.value == false} ) || !hideMode{
                
                    if type == .password{
                       
                            SecureField(_element, text: $_text)
                            .padding()
                            .multilineTextAlignment(.center)
                                .onSubmit {
                                    FocusState.focus_in[_element] = false
                                }
                                .background{
                                    let themeColor:Color = colorScheme == .dark ? .black : .white
                                    RoundedRectangle(cornerRadius: 10).fill(themeColor.opacity(1))
                                    RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                        .shadow(color: .gray, radius: 20)
                                }
        
                    }else
                    if type == .phone{
                        
                            
                            TextField(_element, text: $_text)
                            .padding()
                            .multilineTextAlignment(.center)
                                .onSubmit {
                                    FocusState.focus_in[_element] = false
                                }
                                .background{
                                    let themeColor:Color = colorScheme == .dark ? .black : .white
                                    RoundedRectangle(cornerRadius: 10).fill(themeColor.opacity(1))
                                    RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                        .shadow(color: .gray, radius: 20)
                                }
                                
                                
                        
                        
                        
                    }
                    else
                if type == .text{
                            
                            TextField(_element, text: .init(get: {_text}, set: { entry in
                                //for phone number
                                _text = entry
                            }))
                            .padding()
                            .multilineTextAlignment(.center)
                            .background{
                                let themeColor:Color = colorScheme == .dark ? .black : .white
                                RoundedRectangle(cornerRadius: 10).fill(themeColor.opacity(1))
                                RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                    .shadow(color: .gray, radius: 20)
                            }
                        
                        
                    }
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.spring()){
                if FocusState.focus_in.allSatisfy({$0.value == false}){
                    FocusState.focus_in[_element]?.toggle()
                }else{
                    //return all to false first
                    FocusState.focus_in.forEach { (key: String, value: Bool) in
                        FocusState.focus_in.updateValue(false, forKey: key)
                    }
                    FocusState.focus_in[_element]?.toggle()
                }
            }
        }
        .minimumScaleFactor(0.3)
        .ignoresSafeArea(.keyboard, edges: Edge.Set.bottom)
        
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(_text: .constant("Username"), _element: "utilisateur", type: .phone)
            .environmentObject(focusObjects())
            .environmentObject(Utilisateur())
    }
}
