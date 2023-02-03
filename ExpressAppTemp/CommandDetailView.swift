//
//  CommandDetailView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 08/04/2022.
//

import SwiftUI
import MapKit

struct ExpressGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        GroupBox(configuration)
            .cornerRadius(30)
            .shadow(radius: 2)
            .background(.ultraThinMaterial)
    }
}

struct CommandDetailView: View {
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var userdata:UserData
    @State var all_services_local:[Int:Service]=[:]
    @Binding var show_this:Bool
    @State var _command:Command
    @State var showStatevalues:Bool = false
    @State var date_in = Date()
    @State var date_out = Date()
    @State var modif_condition:Bool = false
    @State var _cart:[Service:Int]=[:]
    @State var add_to_command:Bool = false
    var body: some View {
        GeometryReader { GeometryProxy in
            ScrollView{
                
                Text("Commande : #\(_command.id)")
                    .font(.custom("Ubuntu", size: 30))
                    .padding(.top,50)
                Text("\(_command.date_)")
                    .font(.caption)
                    .opacity(0.7)
                //Total de la commande
                
                Text("Total de la commande")
                    .font(.caption)
                    .padding(.top)
                Text("\(_command.cost.formatted(.currency(code: "EUR")))")
                    .font(.custom("Ubuntu", size: 40))
                
                VStack{
                    //Command List
                    ScrollView(.horizontal){
                        LazyHGrid(rows: [GridItem(.flexible()),GridItem(.flexible())], pinnedViews:.sectionHeaders){
                            // Plus button to add to the cart
                            Section {
                                //Command articles
                                    ForEach(Array(_cart.sorted(by: {$0.value < $1.value})), id: \.key) { service,quantity in
                                        HStack(alignment:.center){
                                            Image(uiImage: (fetchModel.services_Images[service.illustration] ?? UIImage(named: "logo120"))!)
                                                .resizable()
                                                .clipped()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                            
                                            VStack{
                                                Text("\(service.name)")
                                                    .multilineTextAlignment(.leading)
                                                Text("\(quantity)")
                                            }
                                            .background(.bar.opacity(0.7))
                                        }
                                    }
                                
                            } header: {
                                if _command.isEditable{
                                    VStack{
                                        Image(systemName: "plus.cirle")
                                            .resizable()
                                            .clipped()
                                            .scaledToFit()
                                    }
                                    .coordinateSpace(name: "addCommandCard")
                                    .frame(width: 50, height:50, alignment: .center)
                                    .background(.ultraThinMaterial)
                                    .shadow(radius: 3)
                                    .cornerRadius(30)
                                    .onTapGesture {
                                        withAnimation {
                                            add_to_command = true
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.never)
                    .frame(height: 200)
                    // Shipping and recover dates
                    Group {
                        //Recuperation
                        VStack{
                            Label("Récupération", systemImage: "shippingbox.fill")
                            if modif_condition{
                                HStack{
                                    DatePicker(
                                        "Start Date",
                                        selection: $date_in,
                                        in:userdata.dateTime ... Date.distantFuture,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color("xpress"))
                                    .cornerRadius(20)
                                    
                                    Picker(selection: $_command.enter_time) {
                                        ForEach(fetchModel.TIMES_IN_AVAILABLES, id: \.self) { value in
                                            Text("\(value)h à \(value + 1)h").tag("\(value)")
                                            
                                        }
                                    } label: {
                                        Text("Horaire")
                                    }
                                    .pickerStyle(.menu)
                                    .background(.ultraThinMaterial)
                                    .background(Color("xpress").opacity(0.3))
                                    .shadow(radius: 1)
                                    .cornerRadius(20)
                                }
                                .onChange(of: date_in) { _ in
                                    Task{
                                        await fetchModel.FetchTimes(day:date_in.mySQLFormat(), type:"in")
                                        _command.enter_date = date_in.mySQLFormat()
                                        date_out = fetchModel.AddDaysToDate(date: date_in, daysToAdd: userdata.MaxDaysForCard(_cart))
                                        //userdata.currentCommand.return_date = fetchmodel.AddDaysToDate(date: date, daysToAdd: userdata.MaxDaysForCard()).mySQLFormat()
                                        //userdata.currentCommand.return_date = return_date.mySQLFormat()
                                    }
                                    
                                }
                            }
                            
                            
                            Label("\(_command.enter_date.toDate()) entre \(_command.enter_time)H et \(Int(_command.enter_time)! + 1)H", systemImage: "info")
                                .font(.caption2)
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        
                        //Delivery
                        VStack{
                            Label("Livraison", systemImage: "shippingbox.and.arrow.backward.fill")
                            if modif_condition{
                                HStack{
                                    DatePicker(
                                        "Start Date",
                                        selection: $date_out,
                                        //in:fetchModel.AddDaysToDate(date: date_in, daysToAdd:userdata.MaxDaysForCard()) ... Date.distantFuture,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color("xpress"))
                                    .cornerRadius(20)
                                    
                                    Picker(selection: $_command.return_time) {
                                        ForEach(fetchModel.TIMES_OUT_AVAILABLES, id: \.self) { value in
                                            Text("\(value)h à \(value + 1)h").tag("\(value)")
                                            
                                        }
                                    } label: {
                                        Text("Horaire")
                                    }
                                    .pickerStyle(.menu)
                                    .background(.ultraThinMaterial)
                                    .background(Color("xpress").opacity(0.3))
                                    .shadow(radius: 1)
                                    .cornerRadius(20)
                                }
                            }
                            
                        }
                        .onChange(of: date_out) { _ in
                            Task{
                                await fetchModel.FetchTimes(day:date_out.mySQLFormat(), type:"out")
                                _command.return_date = date_in.mySQLFormat()
                                //userdata.currentCommand.return_date = fetchmodel.AddDaysToDate(date: date, daysToAdd: userdata.MaxDaysForCard()).mySQLFormat()
                                //userdata.currentCommand.return_date = return_date.mySQLFormat()
                            }
                        }
                    }
                    Label("\(_command.return_date.toDate()) entre \(_command.return_time)H et \(Int(_command.return_time)! + 1)H", systemImage: "info")
                        .font(.caption2)
                        .foregroundColor(Color.secondary)

                }
            }
            .frame(maxWidth: .infinity, alignment:.top)
            
            //header
            VStack(alignment:.center){
                //back & save buttons
                HStack{
                    //back
                    Button {
                        withAnimation {
                            show_this = false
                        }
                    } label: {
                        Label("retour", systemImage: "arrowshape.backward.circle")
                    }
                    Spacer()
                    
                    //edit button
                    Button {
                        Task{
                            await fetchModel.Put_Command(_command)
                        }
                    } label: {
                        Label("Modifier", systemImage:"square.and.pencil")
                    }
                    .disabled(_command.isEditable)

                }
                .padding()
            }
            .frame( maxWidth:.infinity  , maxHeight: 50, alignment: Alignment.center)
            .background(.bar)
            
            if add_to_command{
                Add_Article_to_COMMAND(_show_this: $add_to_command, cart: $_cart)
            }
            
            if _cart.isEmpty{
                //vue de chargement
                VStack{
                    LoadingView()
                        .overlay(alignment: .center) {
                            Text("Chargement de la commande")
                                .font(.custom("Ubuntu", size:20))
                                .offset(y:100)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
        //.background(.thinMaterial)
        //.background(_command.STATUS_COMMAND == "Sent" ? .blue.opacity(0.3) : .red.opacity(0.1))
        .background(.ultraThinMaterial)
        
        .onAppear{
            Task{
                
                var t = await fetchModel.FetchServices()
                DispatchQueue.main.async{
                    self.all_services_local = t
                }
                print("All services local")
                print(self.all_services_local)
                modif_condition = userdata.hoursBetween(userdata.dateTime,_command.enter_date.toDate(), 48)
                
                //fetchModel.fetchSewing()
                userdata.taskbar = false
                date_in = _command.enter_date.toDate()
                //let r = await fetchModel.Message_to_Cart_review(message: userdata.currentCommand.services_quantity)
                
                _cart = Decode_message(_message: _command.services_quantity)
                
                
            }
        }
        
    }
    func Decode_message(_message:String)->[Service:Int]{
        var r : [Service:Int]=[:]
        print(fetchModel.all_services)
        _message.split(separator: ",").forEach({
            _article in
            let _service_id = Int(_article.split(separator: ":").first!)!
            let _quantity = Int(_article.split(separator: ":").last!)!
            print(fetchModel.all_services)
            if !fetchModel.all_services.isEmpty{
                let _service = fetchModel.all_services[_service_id]
                r[_service!] = _quantity
            }
        })
        return r
    }
}



struct CommandDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommandDetailView(
            show_this: .constant(false),
            _command: Command(_i: 3),
            date_in: Date(),
            date_out: Date()
        ).environmentObject(UserData())
            .environmentObject(FetchModels())
    }
}

