//
//  Add_Article_to_COMMAND.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 24/04/2023.
//

import SwiftUI

struct Add_Article_to_COMMAND: View {
    @Binding var _show_this:Bool
    @Binding var cart:[Service:Int]
    @State var _service_to_add:Service=Service()
    @State var _quantity:Int=Int()
    @StateObject var fetchmodel=FetchModels()
    var body: some View {
        GeometryReader { GeometryProxy in
            VStack(alignment: .center){
                //Card
                HStack{
                    // article choice
                    Picker(selection: $_service_to_add, label: Text("Service")) {
                        ForEach(fetchmodel.services, id: \.self) { service in
                            HStack{
                                Image("logo120")
                                    .resizable()
                                    .scaledToFit()
                                Spacer(minLength: 0)
                                Text(service.name)
                                    .multilineTextAlignment(.leading)
                            }
                            .tag(service)
                            //.padding()
                            
                            
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 200)
                    
                    Spacer(minLength: 30)
                    //Quantity
                    Text("\(cart[_service_to_add] ?? 0)")
                        .font(.custom("ModernAntiqua", size: 50))
                }
                .frame(height: 300)
                .padding()
                
                //buttons
                HStack{
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .onTapGesture {
                            
                        }
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .onTapGesture {
                            
                        }

                }
                .padding(.bottom, 30)
            }
            
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding()
            
            .overlay(alignment: .topLeading) {
                    Image(systemName: "arrow.backward.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 50)
                    .padding(.leading, 20)
                    .onTapGesture {
                        //userdata.Back()
                        withAnimation {
                            _show_this = false
                        }
                    }
                
            }
        }
        .background(.ultraThinMaterial)
        .onAppear{
            Task{
                //await fetchmodel.FetchServices()
            }
            
        }
        
    }
}

struct Add_Article_to_COMMAND_Previews: PreviewProvider {
    static var previews: some View {
        Add_Article_to_COMMAND(_show_this: Binding.constant(true), cart: Binding.constant([Service():3,]))
    }
}
