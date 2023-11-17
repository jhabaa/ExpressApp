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
        GeometryReader {
            let size = $0.size
            
            
            
            ScrollView {
                Divider().padding(.top, 100)
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]) {
                    ForEach(fetchmodel.services, id: \.self) { service in
                        ZStack(alignment:.topTrailing){
                            Image(uiImage: (fetchmodel.services_Images[service.illustration] ?? UIImage(named: "logo120"))!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120,height: 120)
                                .clipped()
                            
                            //number
                            Text("\(cart[service] ?? 0)")
                                .padding(5)
                                .background(Color("xpress").gradient)
                        }
                        //.frame(maxHeight: 120)
                        .onTapGesture(count: 2, perform: {
                            let n = cart[service] ?? 0
                            
                            cart.updateValue(n+1, forKey: service)
                        })
                        
                    }
                }
                
            }
            /*
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
             */
            
            //header
            VStack{
                VStack(alignment:.leading){
                    //back button
                    Button("Retour"){
                        withAnimation {
                            _show_this = false
                        }
                    }
                    //.padding()
                   
                    HStack{
                        Text("Ajouter articles")
                            .font(.title)
                            .bold()
                    }
                }
                .padding()
            }
            .frame(width: size.width, height: 100, alignment:.bottomLeading)
            .background(Color("xpress").gradient.blendMode(.sourceAtop))
            .background(.ultraThinMaterial)
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
