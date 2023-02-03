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
    @EnvironmentObject private var FocusState: focusObjects
    @Binding var _text:String
    @State var _element:String
    @State var type:valid_types
    var body: some View {
        ZStack{
            if FocusState.focus_in[_element]! || FocusState.focus_in.allSatisfy({$0.value == false}){
                
                    if type == .password{
                        SecureField(_element, text: $_text)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .padding()
                            .onSubmit {
                                FocusState.focus_in[_element] = false
                            }
                    }else
                    if type == .phone{
                        TextField(_element, text: .init(get: {_text}, set: { num in
                            // if we have more than 3 characters, we add a space after the third one
                            var temp:[String] = num.replacingOccurrences(of: " ", with:"").map({String($0)})
                            
                            if (temp.count > 3 && temp.count < 17){
                                temp.insert(" ", at: 4)
                                if (temp.count > 7){
                                    temp.insert(" ", at: 7)
                                }
                                if (temp.count > 11){
                                    temp.insert(" ", at: 11)
                                }
                                if (temp.count > 13){
                                    temp.insert(" ", at: 13)
                                }
                            }
                            if (temp.count > 17){
                                temp.removeLast()
                            }
                            
                            userdata.currentUser.phone = temp.joined()
                        }))
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .keyboardType(.phonePad)
                            .padding()
                            .onSubmit {
                                FocusState.focus_in[_element] = false
                            }
                    }
                    else
                if type == .text{
                        TextField(_element, text: .init(get: {_text}, set: { entry in
                            //for phone number
                            _text = entry
                        }))
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .padding()
                            .onSubmit {
                                FocusState.focus_in[_element] = false
                            }
                    }
            }
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .topLeading) {
            Text(_element).font(.caption2)
                .padding(.leading,20)
                .opacity(0.5)
        }
        .cornerRadius(20)
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
        
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(_text: .constant("Username"), _element: "username", type: .password)
    }
}
