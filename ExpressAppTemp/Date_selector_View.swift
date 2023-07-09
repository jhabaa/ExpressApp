//
//  Date_selector_View.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/04/2023.
//

import SwiftUI

//My Date PickerStyle
struct express_date_style:DatePickerStyle{
    func makeBody(configuration: Configuration) -> some View {
        var calendar = Calendar.current
        HStack{
            DatePicker("", selection: configuration.self.$selection, in: configuration.minimumDate! ... configuration.maximumDate!, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "fr"))
                .datePickerStyle(CompactDatePickerStyle())
                .onAppear{
                    //Sort dates
                    var days = configuration.selection.GetAllDates().compactMap { date -> DateValue
                        in
                        //getting Day
                        let day = calendar.component(.day, from: date)
                        //excluding weekends
                        let weekend = calendar.component(.weekday, from: date)
                        if weekend != 1 && weekend != 7 {
                            return DateValue(day: day, date: date)
                        }
                        return DateValue(day: -0, date: date)
                        
                    }
                    //On ajuiste le jour à la date
                    let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
                    print("first day week \(firstWeekDay)")
                    for _ in 1..<firstWeekDay - 1{
                        days.insert(DateValue(day: -1, date: Date()), at: 0)
                    }
                    //delete values with 0 which are week ends
                    days = days.filter{$0.day != 0}
                    calendar = Calendar(identifier: .gregorian)
                    calendar.locale = Locale(identifier: "fr")
                    var newRange = Date() ... Date.distantFuture
                    
                    var excludedComponents = DateComponents(weekday: 4)
                }
        }
    }
}

struct Date_selector_View: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var fetchmodel:FetchModels
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var utilisateur:Utilisateur
    @State var dateIn:Date = Date()
    @State var dateOut:Date = Date()
    @Binding var show:Bool
    @State var currentMonth:Int = 0
    @State var currentMonth_2:Int = 0
    @State var fill_date_in:Bool = false
    @State var fill_date_out:Bool = false
    @Namespace var selected_date:Namespace.ID
    @State var time_to_wait:Int = 1
    @State var date_limit:Date=Date()
    @State var adress_modifier:Bool = false
    @State var adress_is_valid:Bool = false
    @State var sure_to_command:Bool = false
    @EnvironmentObject var panier:Panier
    //@Binding var command_passed:Bool
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack (spacing:0) {
                VStack(spacing:0){
                    Text("Total")
                        //.offset(y:-30)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(commande.TotalCost.formatted(.currency(code: "EUR")))")
                        .font(.custom("Ubuntu", size: 40))
                }
                .padding()
                .frame(width: size.width,height: 130, alignment:.bottom)
                
                //.background(.bar)
                
                List {
                    Section {} footer: {
                        CalendarPart()
                    }
                    
                    Section {} footer: {
                        CalendarPart_2()
                    }
                    
                    Section {}header: {
                            VStack{
                                Text(utilisateur.this.adress)
                                    .font(.custom("Ubuntu", size: 15))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth:.infinity,maxHeight: 200)
                            .background(Color("xpress").opacity(0.2).gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            .onTapGesture {
                                adress_modifier.toggle()
                            }
                    }
                footer:{
                    Text("Tapez pour modifier l'adresse de cette livraison")
                }
                    
                }
                .listStyle(.grouped)
                .navigationTitle("Récupération & livraison")
            }
            .frame(maxWidth: size.width)
            .ignoresSafeArea(edges: .all)
            
            
            //Valid button in overlay like every others command
            .overlay(alignment: .bottom) {
                HStack{
                    Text("Continuer")
                        .bold()
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            withAnimation(.priceJump()){
                                sure_to_command.toggle()
                            }
                        }
                        .disabled(!commande.this.isValid)
                }
                .background(Color("xpress").opacity(0.7).gradient)
                .clipShape(Capsule())
                .shadow(radius: 5)
                .padding(.bottom, 50)
            }
            
            //on appear, get the max treatment time
            .onAppear{
                time_to_wait = commande.daysNeeded()
            }
            
            //back button
            Button(action: {
                withAnimation(.priceJump()){
                    show.toggle()
                }
            }, label: {
                Text("Retour")
            })
            .clipped()
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(Color("xpress").gradient)
            .shadow(radius: 10, x: 2.1, y: 1)
            .offset(y:50)
            
            //view to modify adress
            if adress_modifier{
                AdressEditView(_show: $adress_modifier)
            }
            
            // Are you sure that you want to validate this command ?
            if !sure_to_command{
                Sure_to_command()
            }
        }
        .clipped()
        .background(Color("xpress").opacity(0.3).gradient)
        .edgesIgnoringSafeArea(.all)
        
    }
    @State var days:[String]=["lun","mar","mer","jeu","ven"]
    @ViewBuilder
    public func CalendarPart() -> some View{
        //let size = $0.size
        VStack(alignment: .center, spacing: 20) {
            //Mois et année
            
            LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]){
                //Bouton du mois précédent
                HStack(spacing:0){
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFill()
                        .clipped()
                    Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth-1))[1])")
                        .font(.caption2)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        currentMonth -= 1
                    }
                }
                .disabled(getCurrentMonth(currentMonth: currentMonth ) <= Date())
                //Month and year
                Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth))[1])")
                    .bold()
                    
                    .overlay(alignment: .topTrailing) {
                        Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth))[0])")
                            .offset(y:-10)
                            .font(.caption2)
                            //.frame(width: 100, alignment: .center)
                    }
                    
                
                HStack(spacing:0){
                    Text("\(extraData(a:getNextMonth(currentMonth: currentMonth))[1])")
                        .font(.caption2)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFill()
                        .clipped()
                }
                
                    .onTapGesture {
                        withAnimation(.spring()) {
                            currentMonth += 1
                            //getCurrentMonth(currentMonth: currentMonth)
                        }
                    }
                
            }.frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.center)
                .padding()
                .background(.bar)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            //
            ScrollView(.horizontal){
                let cols = Array(repeating: GridItem(.flexible()), count: 1)
                //Calendar
                HStack{
                    Section {
                        ForEach(extractDates(currentMonth: currentMonth)){value in
                            //CadView(value: value)
                            if !(value.day == -1 || value.date < Date()){
                                VStack{
                                    Text("\(extraData(a:value.date)[2])")
                                    Text("\(value.day)")
                                        .monospacedDigit()
                                        .padding(5)
                                        .frame(width:50)
                                }
                                .background(value.date == dateIn ? .blue.opacity(0.2) : .gray.opacity(0.1))
                                // Lets set a fixed size
                                //.foregroundColor(value.date == dateIn ? .white : .primary)
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    dateIn = value.date
                                    commande.setDateIn(value.date)
                                }
                            }
                        }
                    }
                    .onChange(of: dateIn) { _ in
                        Task{
                            await fetchmodel.FetchTimes(day:dateIn.mySQLFormat(), type: "in")
                            //userdata.currentCommand.enter_date = dateIn.mySQLFormat()
                            commande.setDateIn(dateIn)
                           /// userdata.currentCommand.return_date = fetchmodel.AddDaysToDate(date: dateIn, daysToAdd: userdata.MaxDaysForCard(userdata.cart)).mySQLFormat()
                            date_limit = dateIn.set_limit(time_to_wait)
                        }
                    }
                }
                
                
            }
            .cornerRadius(2)
            
            HStack {
                //If time is not selected, ask to select one
                if commande.this.enter_time == "0"{
                    Label("Selectionner créneau", systemImage: "info.circle")
                        .foregroundColor(.red)
                }
                    
                Picker(selection: $commande.this.enter_time, label: Text("Creneaux")) {
                    ForEach(fetchmodel.TIMES_IN_AVAILABLES, id: \.self) { value in
                        Text("\(value)h à \(value + 1)h")
                            .tag("\(value)")
                    }
                }
                .foregroundColor(Color.primary)
                .labelsHidden()
            }
            .padding(2)
            .background()
            .clipShape(Capsule())
        }
        //.padding(.vertical, 10)
        //.background(.red)
    }
    
    @ViewBuilder
    public func Sure_to_command()->some View{
        GeometryReader { GeometryProxy in
            let size = GeometryProxy.size
            VStack{
                // I change my mind

                // Recap card
                LazyVGrid(columns: [GridItem(),GridItem()],spacing: 0) {
                    // On the left side, we have the shipping adress
                    VStack{
                        Text("Adresse:")
                        Text(utilisateur.this.adress)
                            .multilineTextAlignment(.leading)
                            
                    }
                    VStack(alignment:.trailing){
                        HStack(alignment:.center, spacing:0){
                            Text("Sous-total: ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(commande.getCost.formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                        HStack(alignment:.center, spacing:0){
                            Text("Livraison: ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(commande.this.delivery.formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                        HStack(alignment:.center, spacing:0){
                            Text("Reduction: -")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(commande.this.discount.formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                        HStack(alignment:.center, spacing:0){
                            Text("Total: ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(commande.TotalCost.formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // I've changed my mind
                    HStack(alignment: .center, content: {
                        Text("Annuler")
                            .opacity(0.8)
                    })
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background()
                    .onTapGesture {
                        withAnimation(.spring()){
                            sure_to_command.toggle()
                        }
                    }
                    
                    HStack(alignment: .center, content: {
                        Text("Confirmer")
                            .bold()
                    })
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background()
                    .onTapGesture {
                        Task{
                            //Now validation of the command
                            await commande.validate(utilisateur)
                            let _ = await commande.PushCommand()
                            
                            if commande.confirmed{
                                sure_to_command = false
                                show = false
                            }
                            #warning("implement those functions")
                            ///userdata.currentCommand.services_quantity = userdata.cartToString(Command.current_cart)
                            ///let r = await fetchmodel.PushCommand(commande: userdata.currentCommand)
                            /*
                            DispatchQueue.main.async {
                                //command_id = r
                                sure_to_command.toggle()
                                show.toggle()
                                //userdata.command_confirmation = r == 0 ? false : true
                            }
                        */
                        }
                        
                    }
                    
                    
                }
                //.padding(.vertical, 20)
                .frame(width: size.width-30)
                .background(Color("xpress").opacity(0.4).gradient)
                .cornerRadius(20, antialiased: true)
                .shadow(radius: 20)
                .overlay(alignment: .trailing) {
                    /*
                    ZStack(alignment:.trailing){
                        ZStack(alignment:.trailing){
                            Rectangle().fill(Color("xpress")).frame(width: 10, height: 50)
                                .blur(radius: 2)
                            Rectangle().fill(RadialGradient(colors: [Color("xpress").opacity(0.6),Color("xpress").opacity(0.0)], center: .trailing, startRadius: 0, endRadius: 100)).frame(width: 100, height: 200)
                        }
                        ZStack(alignment: .topTrailing) {
                            Image("logo120")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                                .clipShape(Circle())
                                .offset(y:-100)
                        }
                    }*/
                }
                .padding()
                
                
            }
            .frame(maxWidth: .infinity, maxHeight:.infinity)
        }
        .frame(alignment: .center)
        .background(Color("xpress").opacity(0.4))
        .background(.bar)
    }
    //Shipping dates
    @ViewBuilder
    public func CalendarPart_2() -> some View{
        //let size = $0.size
        VStack(alignment: .center, spacing: 20) {
            //Mois et année
            LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]){
                //Bouton du mois précédent
                HStack(spacing:0){
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFit()
                        .clipped()
                    Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2-1))[1])")
                        .font(.caption2)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        currentMonth_2 -= 1
                    }
                }
                .disabled(getCurrentMonth(currentMonth: currentMonth_2 ) <= date_limit)
                //Month and year
                Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2))[1])")
                    .bold()
                    .overlay(alignment: .topTrailing) {
                        Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2))[0])")
                            .offset(y:-10)
                            .font(.caption2)
                    }
                HStack{
                    Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2+1))[1])")
                        .font(.caption2)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFill()
                        .clipped()
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        currentMonth_2 += 1
                        getCurrentMonth(currentMonth: currentMonth_2)
                    }
                    }
                
            }.frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.center)
                .padding()
                .background(.bar)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            //
            ScrollView(.horizontal){
                let cols = Array(repeating: GridItem(.flexible()), count: 1)
                //Calendar
                HStack{
                    Section {
                        ForEach(extractDates(currentMonth: currentMonth_2)){value in
                            //CadView(value: value)
                            if (value.day == -1){
                                VStack{
                                    
                                }
                            }
                            if(value.date > date_limit && value.day != -1){
                                VStack{
                                    Text("\(extraData(a:value.date)[2])")
                                    Text("\(value.day)")
                                        .monospacedDigit()
                                        .padding(5)
                                        .frame(width:50)
                                }
                                .background(value.date == dateOut ? .green : .black.opacity(0.1))
                                // Lets set a fixed size
                                .foregroundColor(value.date == dateOut ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                .onTapGesture {
                                    dateOut = value.date
                                }
                            }
                            //   }
                        }
                    }
                }
            }
            .cornerRadius(2)
            .onChange(of: dateOut) { _ in
                Task{
                    await fetchmodel.FetchTimes(day:dateIn.mySQLFormat(), type: "out")
                    commande.setDateOut(dateOut)
                    //userdata.currentCommand.return_date = dateOut.mySQLFormat()
                }
            }
            //.padding(.horizontal, 10)
            
            HStack {
                if commande.this.enter_time == "0"{
                    Label("Selectionner créneau", systemImage: "info.circle")
                        .foregroundColor(.red)
                }
                Picker(selection: $commande.this.return_time, label: Text("Creneaux")) {
                    ForEach(fetchmodel.TIMES_OUT_AVAILABLES, id: \.self) { value in
                        Text("\(value)h à \(value + 1)h")
                            .tag("\(value)")
                    }
                }
                .foregroundColor(Color.primary)
                .labelsHidden()
            }
            .padding(2)
            .background()
            .clipShape(Capsule())
        }
        //.padding(.vertical, 10)
        //.background(.red)
    }
}

struct Date_selector_View_Previews: PreviewProvider {
    static var previews: some View {
        Date_selector_View(show: Binding.constant(true))
            .environmentObject(FetchModels())
            .environmentObject(UserData())
            .environmentObject(Panier())
            .environmentObject(Commande())
            .environmentObject(Utilisateur())
            .environmentObject(Coupons())
    }
}
