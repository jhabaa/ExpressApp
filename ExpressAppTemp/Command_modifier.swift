//
//  Command_modifier.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/04/2023.
//

import SwiftUI

struct Command_modifier: View {
    @EnvironmentObject var fetchmodel:FetchModels
    @EnvironmentObject var userdata : UserData
    @Namespace var namespace : Namespace.ID
    @State var edit_mode:Bool=false
    @State var dateIn:Date=Date()
    @State var dateOut:Date = Date()
    @State var service_to_add : Service = Service()
    @State var service_add_card:Bool = false
    @State var command_to_review:Command
    @State var cart_to_review:[Service:Int]
    @Binding var show:Bool
    var body: some View {
        GeometryReader {
            let size = $0.size
            ScrollView{
                VStack(alignment: .center, spacing: 5) {
                    Text("Numéro de commande # \(command_to_review.id)")
                        .font(.headline)
                    Text(command_to_review.date_)
                }
                .frame(maxWidth: .infinity)
                
                //toggle button to edit
                Toggle(isOn: $edit_mode) {
                    Label("Modifier", systemImage: "pencil.line")
                }
                .toggleStyle(.button)
                
                // Elements in the cart
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(pinnedViews: .sectionHeaders) {
                        Section {
                            ForEach(fetchmodel.cart_to_review.keys.map({$0}), id: \.self) { service in
                                VStack{
                                    Text("\(fetchmodel.cart_to_review[service]!)").padding(.top)
                                    Text("\(service.name)")
                                    Spacer()
                                    Text((service.cost * Decimal(cart_to_review[service]!)) .formatted(.currency(code: "EUR")))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal)
                                        .background(Capsule().fill(Color("xpress")))
                                }
                                .frame(width: 100, height: 120)
                                .background(.ultraThinMaterial)
                            }
                            
                        } header: {
                            VStack{
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                            }
                            .frame(width: 100, height: 120)
                            .background(Color("xpress"))
                            .coordinateSpace(name: "card")
                            .matchedGeometryEffect(id: "card", in: namespace)
                            //tap to add a new service
                            .onTapGesture {
                                withAnimation (.spring()){
                                    service_add_card.toggle()
                                }
                            }
                        }
                        
                        
                    }
                }
                
                //Dates modifier if possible
                VStack{
                    //Date & time IN
                    HStack{
                        // DateIn image
                        Image(systemName: "shippingbox.fill")
                            .foregroundColor(.blue)
                        //DateIn selection
                        DatePicker(
                            "Start Date",
                            selection: $dateIn,
                            in: dateRange,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "fr"))
                        .foregroundColor(.indigo)
                        .datePickerStyle(.compact)
                        .onChange(of: dateIn) { _ in
                            Task{
                                await fetchmodel.FetchTimes(day:dateIn.mySQLFormat(), type: "in")
                                fetchmodel.command_to_review.enter_date = dateIn.mySQLFormat()
                                fetchmodel.command_to_review.return_date = fetchmodel.AddDaysToDate(date: dateIn, daysToAdd: userdata.MaxDaysForCard(cart_to_review)).mySQLFormat()
                            }
                        }
                        Spacer()
                        //Time_In selection
                        //Select the TimeIN value
                        Picker(selection: $fetchmodel.command_to_review.enter_time, label: Text("Creneaux")) {
                            ForEach(fetchmodel.TIMES_IN_AVAILABLES, id: \.self) { value in
                                Text("\(value)h à \(value + 1)h")
                                    .tag("\(value)")
                            }
                        }
                        .labelsHidden()
                    }
                    .padding()
                    //date & time OUT
                    
                    HStack{
                        Image(systemName: "shippingbox.and.arrow.backward.fill")
                            .foregroundColor(Color("xpress"))
                        DatePicker(
                            "End Date",
                            selection: $dateOut,
                            in: fetchmodel.AddDaysToDate(date: dateIn, daysToAdd: userdata.MaxDaysForCard(cart_to_review)) ... .distantFuture,
                            displayedComponents: [.date]
                            
                        )
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "fr"))
                        
                        .foregroundColor(.indigo)
                        .datePickerStyle(.compact)
                        .onChange(of: dateOut) { _ in
                            Task{
                                await fetchmodel.FetchTimes(day:dateOut.mySQLFormat(), type:"out")
                                
                                fetchmodel.command_to_review.return_date = dateOut.mySQLFormat()
                            }
                            
                        }
                        
                        Spacer()
                        
                        //Time Out selector
                        Picker(selection: $fetchmodel.command_to_review.return_time, label: Text("Creneaux")) {
                            ForEach(fetchmodel.TIMES_OUT_AVAILABLES, id: \.self) { value in
                                Text("\(value)h à \(value + 1)h")
                                    .tag("\(value)")
                            }
                        }
                        .labelsHidden()
                    }
                    .padding()
                }
                .padding(2)
                .frame(maxWidth: .infinity)
                .background{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
                .padding()
                .overlay(alignment: .center) {
                    Text("Jour et tranche horaire")
                        .font(.caption)
                }
            }
            
            
            // Add object to command overlay
            if service_add_card{
                VStack(alignment: .center, spacing: 20) {
                    VStack{
                        Text("Service à ajouter")
                            .font(.headline)
                        Picker(selection: $service_to_add, label: Text("Service")) {
                            ForEach(fetchmodel.all_services.values.map({$0}), id: \.self) { service
                                 in
                                Text(service.name).tag(service)
                                
                            }
                        }
                        .padding(.horizontal)
                        .labelStyle(.titleAndIcon)
                        .pickerStyle(.wheel)
                        
                        //quantity
                        HStack{
                            Text("\(fetchmodel.cart_to_review[service_to_add] ?? 0)").padding()
                                .font(.custom("Outfit", size: 40))
                            HStack{
                                Image(systemName: "minus.circle")
                                    .resizable()
                                    .scaledToFit()
                                .frame(width: 30)
                                .padding()
                                .onTapGesture {
                                    //quantity -= quantity > 0 ? 1 : 0
                                    fetchmodel.RemoveServiceFromCart_review(s: service_to_add)
                                }
                                
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .padding()
                                    .onTapGesture {
                                        fetchmodel.AddServiceFromCart_review(s: service_to_add)
                                    }
                            }
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .coordinateSpace(name: "card")
                    .background{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("xpress").opacity(0.1))
                    }
                    .padding()
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .foregroundColor(.blue)
                            .padding()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    service_add_card.toggle()
                                }
                            }
                    }
                }
                .frame(width: size.width, height: size.height)
                .background(.ultraThinMaterial)
            }
            
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .topLeading) {
            Image(systemName: "arrow.backward.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40)
                .padding(.top, 50)
                .padding(.leading, 20)
                .onTapGesture {
                    //userdata.Back()
                    show = false
                }
        }
        .onAppear{
            Task{
                await fetchmodel.FetchServices()
                print("Cart is current : \(cart_to_review)")
                print("Cart is current : \(fetchmodel.cart_to_review)")
            }
        }
    }
}

struct Command_modifier_Previews: PreviewProvider {
    static var previews: some View {
        Command_modifier(dateIn: Date(), dateOut: Date(), command_to_review: Command(), cart_to_review: [Service() : 1], show: Binding.constant(true)).environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}
